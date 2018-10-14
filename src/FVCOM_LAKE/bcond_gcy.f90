!==============================================================================|
!     SET BOUNDARY CONDITIONS FOR ALMOST ALL VARIABLES                         |
!                                                                              |
!         idx: identifies which variables are considered                       |
!              1=tidal forcing                                                 |
!              2=solid bcs for external mode uaf and vaf                       |
!              3=solid bcs for internal mode uf and vf                         |
!              4=open bcs for s and t                                          |
!              5=solid bcs for internal mode u and v                           |
!              6=unused                                                        |
!              7=unused                                                        |
!              8=the surface forcings for internal mode                        |
!              9=the surface forcings for external mode                        |
!                                                                              |
!==============================================================================|

   SUBROUTINE BCOND_GCY(IDX,K_RK)

!==============================================================================|
   USE ALL_VARS
   USE BCS
   USE MOD_OBCS

#  if defined (WATER_QUALITY)
   USE MOD_WQM
#  endif
#  if defined (MULTIPROCESSOR)
   USE MOD_PAR
#  endif
#  if defined (WET_DRY)
   USE MOD_WD
#  endif
   IMPLICIT NONE
   INTEGER, INTENT(IN) :: IDX
   REAL(SP) :: ZREF(KBM1),ZREFJ(KBM1),TSIGMA(KBM1),SSIGMA(KBM1)
   REAL(SP) :: TTMP(KBM1),STMP(KBM1),TREF(KBM1),SREF(KBM1)
   REAL(SP) :: PHY_Z(KBM1),PHY_Z1(KBM1)
   REAL(SP) :: TT1(KBM1),TT2(KBM1),SS1(KBM1),SS2(KBM1)
   REAL(SP) :: TIME1,FACT,UFACT,FORCE,UI,VI,UNTMP,VNTMP,TX,TY,HFLUX
   REAL(SP) :: DTXTMP,DTYTMP,SPRO,WDS,CD,SPCP,ROSEA
   REAL(SP) :: PHAI_IJ,ALPHA1,DHFLUXTMP,DHSHORTTMP,HSHORT,TIMERK1
   REAL(SP) :: ETAXFER,ANGALONG,ANGWIND,WNDALONG,TXJMP2,TYJMP2,RHOILST,RHOINT,CUMEL
   REAL(SP) :: DXBC,ETATAN,CC,DELTAN,CP

   INTEGER  I,J,K,I1,I2,J1,J2,II,L1,L2,IERR
   INTEGER  NNOW,NLAST,NBCJMP,IGL
   INTEGER  N1,K_RK

   SELECT CASE(IDX)


!==============================================================================|
   CASE(1) !Surface Elevation Boundary Conditions (Tidal Forcing)              !
!==============================================================================|
   CALL BCOND_ASL
   CALL BCOND_ASL_CLP
   CALL BCOND_GWI(K_RK)
   CALL BCOND_BKI(K_RK)
   CALL BCOND_ORE(K_RK)

!
!--Allow setup/down on north boundary in response to longshore wind
!--Corrects for Wind-Driven Barotropic Response (See Schwing 1989)
!--Implemented by Jamie Pringle
!

!  CASEUNIQUE
   IF(CASENAME == "gom")THEN
     ETAXFER = 0.5_SP
     ANGALONG = 68.0_SP/360.0_SP*6.283185_SP
     DO J=1,IOBCN
       II = I_OBC_N(J)
       IGL = II
#      if defined (MULTIPROCESSOR)
       IF(PAR) IGL = NGID(II)
#      endif
       IF(IGL == 1 .OR. IGL == 2)THEN
#        if !defined (SEMI_IMPLICIT)
         TXJMP2 = WUSURF2(2)*1000.0_SP
         TYJMP2 = WVSURF2(2)*1000.0_SP
#        else
         TXJMP2 = -WUSURF(2)*1000.0_SP
         TYJMP2 = -WVSURF(2)*1000.0_SP
#        endif
         ANGWIND=ATAN2(TYJMP2,TXJMP2)-ANGALONG
         WNDALONG=COS(ANGWIND)*SQRT(TXJMP2**2+TYJMP2**2)
         IF (IGL == 1) THEN
           ELF(II)=ELF(II)-WNDALONG*ETAXFER
         ELSEIF (IGL == 2) THEN
           ELF(II)=ELF(II)-0.5_SP*WNDALONG*ETAXFER
         ENDIF
       ENDIF
     END DO
   END IF
!  END CASEUNIQUE

!  CASEUNIQUE
   IF(CASENAME == "gom")THEN

     CUMEL=0.0_SP
     DO NBCJMP=1,NOBCGEO
       NNOW=IBCGEO(NBCJMP)

       !INTEGRATE RHO IN DEPTH, CONVERT TO MKS UNITS DAMIT
       RHOILST=RHOINT
       RHOINT=0.0_SP
       DO K=1,KBM1
         RHOINT=RHOINT+(1.0_SP+RHO1(NNOW,K))*1.0E3_SP*DZ(NNOW,K)
       END DO

       !FIND DENSITY GRADIENT, AND MODIFY BOUNDARY ELEVATION
       !NOTE THE FACTOR OF 1000 AND 2 TO COMPENSATE FOR THE
       !FACT THAT THE MODEL STORES RHO1 AS SIGMA, AND IN CGS.
       IF (NBCJMP /= 1) THEN
         NLAST=IBCGEO(NBCJMP-1)
         DXBC=SQRT((VX(NNOW)-VX(NLAST))**2+(VY(NNOW)-VY(NLAST))**2)
         ETATAN=-(1.0_SP/(0.5_SP*(RHOINT+RHOILST))) &
               *((H(NNOW)*RHOINT-H(NLAST)*RHOILST)/DXBC &
               -0.5_SP*1.0e3_SP*(2.0_SP+RHO1(NNOW,KBM1)+RHO1(NLAST,KBM1)) &
                *(H(NNOW)-H(NLAST))/DXBC)
         CUMEL=CUMEL+ETATAN*DXBC
         ELF(NNOW)=ELF(NNOW)+CUMEL

       ENDIF
     END DO

  END IF
! END CASEUNIQUE


!==============================================================================|
   CASE(2) !External Mode Velocity Boundary Conditions                         |
!==============================================================================|
   DO I=1,N
!
!--1 SOLID BOUNDARY EDGE-------------------------------------------------------|
!
     IF(ISBCE(I) == 1) THEN
       ALPHA1=ALPHA(I)
       IF(NUMQBC > 0) THEN
         IF(INFLOW_TYPE == 'node') THEN
           DO J=1,NUMQBC
             I1=INODEQ(J)
             J1=NBVE(I1,1)
             J2=NBVE(I1,NTVE(I1))
             IF((I == J1).OR.(I == J2)) THEN
               UNTMP=UAF(I)*COS(ANGLEQ(J))+VAF(I)*SIN(ANGLEQ(J))
               VNTMP=-UAF(I)*SIN(ANGLEQ(J))+VAF(I)*COS(ANGLEQ(J))
               UNTMP=MAX(UNTMP,0.0_SP)
               UAF(I)=UNTMP*COS(ANGLEQ(J))-VNTMP*SIN(ANGLEQ(J))
               VAF(I)=UNTMP*SIN(ANGLEQ(J))+VNTMP*COS(ANGLEQ(J))
               GOTO 21
             END IF
           END DO
         ELSE IF(INFLOW_TYPE == 'edge') THEN
           DO J=1,NUMQBC
             J1=ICELLQ(J)
             IF(I == J1) THEN
               UNTMP=UAF(I)*COS(ANGLEQ(J))+VAF(I)*SIN(ANGLEQ(J))
               VNTMP=-UAF(I)*SIN(ANGLEQ(J))+VAF(I)*COS(ANGLEQ(J))
               UNTMP=MAX(UNTMP,0.0_SP)
               UAF(I)=UNTMP*COS(ANGLEQ(J))-VNTMP*SIN(ANGLEQ(J))
               VAF(I)=UNTMP*SIN(ANGLEQ(J))+VNTMP*COS(ANGLEQ(J))
               GOTO 21
             END IF
           END DO
         END IF

       END IF

21     CONTINUE
     END IF
   END DO

!==============================================================================|
   CASE(3) !3-D Velocity Boundary Conditions                                   !
!==============================================================================|
   DO I= 1, N
     DO K =1, KBM1
       IF(ISBCE(I) == 1)THEN
         ALPHA1=ALPHA(I)
         IF(NUMQBC >= 1)THEN
           IF(INFLOW_TYPE == 'node')THEN
             DO J = 1,NUMQBC
               I1 = INODEQ(J)
               J1 = NBVE(I1,1)
               J2 = NBVE(I1,NTVE(I1))
               IF((I == J1) .OR. (I == J2))THEN
                 UNTMP =  UF(I,K)*COS(ANGLEQ(J))+VF(I,K)*SIN(ANGLEQ(J))
                 VNTMP = -UF(I,K)*SIN(ANGLEQ(J))+VF(I,K)*COS(ANGLEQ(J))
                 UNTMP = MAX(UNTMP,0.0_SP)
                 UF(I,K) = UNTMP*COS(ANGLEQ(J))-VNTMP*SIN(ANGLEQ(J))
                 VF(I,K) = UNTMP*SIN(ANGLEQ(J))+VNTMP*COS(ANGLEQ(J))
                 GOTO 31
               END IF
             END DO
           ELSE IF(INFLOW_TYPE == 'edge')THEN
             DO J = 1,NUMQBC
               J1 = ICELLQ(J)
               IF(I == J1)THEN
                 UNTMP =  UF(I,K)*COS(ANGLEQ(J))+VF(I,K)*SIN(ANGLEQ(J))
                 VNTMP = -UF(I,K)*SIN(ANGLEQ(J))+VF(I,K)*COS(ANGLEQ(J))
                 UNTMP = MAX(UNTMP,0.0_SP)
                 UF(I,K) = UNTMP*COS(ANGLEQ(J))-VNTMP*SIN(ANGLEQ(J))
                 VF(I,K) = UNTMP*SIN(ANGLEQ(J))+VNTMP*COS(ANGLEQ(J))
                 GOTO 31
               END IF
             END DO
           ELSE
             PRINT*, 'INFLOW_TYPE NOT CORRECT'
             CALL PSTOP
           END IF
         END IF

31       CONTINUE
       END IF
     END DO
   END DO
!==============================================================================|
   CASE(4) !Blank                                                              !
!==============================================================================|

!==============================================================================|
   CASE(5) !!SOLID BOUNDARY CONDITIONS ON U AND V                              !
!==============================================================================|
   DO I = 1, N
     DO K = 1, KBM1
       IF(ISBCE(I) == 1)THEN
         ALPHA1=ALPHA(I)
         IF(NUMQBC >= 1)THEN
           IF(INFLOW_TYPE == 'node')THEN
             DO J=1,NUMQBC
               I1=INODEQ(J)
               J1=NBVE(I1,1)
               J2=NBVE(I1,NTVE(I1))
               IF((I == J1).OR.(I == J2))THEN
                 UNTMP=U(I,K)*COS(ANGLEQ(J))+V(I,K)*SIN(ANGLEQ(J))
                 VNTMP=-U(I,K)*SIN(ANGLEQ(J))+V(I,K)*COS(ANGLEQ(J))
                 UNTMP=MAX(UNTMP,0.0_SP)
                 U(I,K)=UNTMP*COS(ANGLEQ(J))-VNTMP*SIN(ANGLEQ(J))
                 V(I,K)=UNTMP*SIN(ANGLEQ(J))+VNTMP*COS(ANGLEQ(J))
                 GOTO 51
               END IF
             END DO
           ELSE IF(INFLOW_TYPE == 'EDGE')THEN
             DO J=1,NUMQBC
               J1=ICELLQ(J)
               IF(I == J1)THEN
                 UNTMP=U(I,K)*COS(ANGLEQ(J))+V(I,K)*SIN(ANGLEQ(J))
                 VNTMP=-U(I,K)*SIN(ANGLEQ(J))+V(I,K)*COS(ANGLEQ(J))
                 UNTMP=MAX(UNTMP,0.0_SP)
                 U(I,K)=UNTMP*COS(ANGLEQ(J))-VNTMP*SIN(ANGLEQ(J))
                 V(I,K)=UNTMP*SIN(ANGLEQ(J))+VNTMP*COS(ANGLEQ(J))
                 GOTO 51
               END IF
             END DO
           ELSE
             PRINT*, 'INFLOW_TYPE NOT CORRECT'
             CALL PSTOP
           END IF
         END IF

51       CONTINUE
       END IF
     END DO
   END DO



!==============================================================================|
   CASE(6) !Blank                                                              !
!==============================================================================|

!==============================================================================|
   CASE(7) !Blank                                                              !
!==============================================================================|

!==============================================================================|
   CASE(8) !!SURFACE FORCING FOR INTERNAL MODE                                 !
!==============================================================================|

!
!--Fresh Water Discharge-------------------------------------------------------|
!
   IF(NUMQBC > 0)THEN
     CALL BRACKET(QBC_TM,THOUR,L1,L2,FACT,UFACT,IERR)
     QDIS(:) = UFACT*DQDIS(:,L1) + FACT*DQDIS(:,L2)
     TDIS(:) = UFACT*DTDIS(:,L1) + FACT*DTDIS(:,L2)
     SDIS(:) = UFACT*DSDIS(:,L1) + FACT*DSDIS(:,L2)
     QDIS    = QDIS*RAMP

#  if defined (WATER_QUALITY)
     DO N1 = 1, NB
       WDIS(:,N1) = UFACT*DWDIS(:,N1,L1) + FACT*DWDIS(:,N1,L2)
     END DO
#  endif

   END IF


   IF(M_TYPE == 'uniform') THEN

     CALL BRACKET(UMF_TM,THOUR,L1,L2,FACT,UFACT,IERR)
!
!----Surface Evaporation and Precipitation---------------------------------------|
!
     QPREC3 = UFACT*UQPREC(L1) + FACT*UQPREC(L2)
     QEVAP3 = UFACT*UQEVAP(L1) + FACT*UQEVAP(L2)
     
     QPREC3 = QPREC3*0.001_SP
     QEVAP3 = QEVAP3*0.001_SP

!
!--- Heat Flux and Short Wave Radiation----------------------------------------!
!

     SPCP=4.2174E3_SP
     ROSEA = 1.023E3_SP
     SPRO = SPCP*ROSEA
     WTSURF(:) = UFACT*UHFLUX(L1)  + FACT*UHFLUX(L2)
     SWRAD(:)  = UFACT*UHSHORT(L1) + FACT*UHSHORT(L2)
     WTSURF    = -WTSURF/SPRO*RAMP
     SWRAD     = -SWRAD/SPRO*RAMP

!
!--- Wind Stress for the Internal Mode-----------------------------------------!
!

     TX = UFACT*UWIND(L1) + FACT*UWIND(L2)
     TY = UFACT*VWIND(L1) + FACT*VWIND(L2)

     IF(WINDTYPE == 'speed')THEN
       WDS=SQRT(TX*TX+TY*TY)
       CD=1.2E-3
       IF (WDS >= 11.0_SP) CD=(0.49_SP+0.065_SP*WDS)*1.E-3_SP
       IF (WDS >= 25.0_SP) CD=(0.49_SP+0.065_SP*25.0_SP)*1.E-3_SP
       TX=1.2_SP*CD*TX*WDS
       TY=1.2_SP*CD*TY*WDS
       UUWIND(:)=-1.0E-3_SP*TX
       VVWIND(:)=-1.0E-3_SP*TY
       WUSURF(:)=-1.0E-3_SP*TX*RAMP
       WVSURF(:)=-1.0E-3_SP*TY*RAMP
     ELSE IF(WINDTYPE == 'stress') THEN
       TX=0.001_SP*TX
       TY=0.001_SP*TY
       UUWIND(:)=-TX
       VVWIND(:)=-TY
       WUSURF(:)=-TX*RAMP
       WVSURF(:)=-TY*RAMP
     END IF

   END IF !! M_TYPE='uniform'


   IF(M_TYPE == 'non-uniform')THEN

     QPREC3 = 0.0_SP
     QEVAP3 = 0.0_SP
     IF(EVP_FLAG)THEN
       CALL BRACKET(EVP_TM,THOUR,L1,L2,FACT,UFACT,IERR)
!
!----Surface Evaporation and Precipitation---------------------------------------|
!
       IF(IERR /= -1)THEN
         QPREC3(1:M) = UFACT*DQPREC(1:M,L1) + FACT*DQPREC(1:M,L2)
         QEVAP3(1:M) = UFACT*DQEVAP(1:M,L1) + FACT*DQEVAP(1:M,L2)
       END IF

       QPREC3 = QPREC3*0.001_SP
       QEVAP3 = QEVAP3*0.001_SP
     END IF

!
!--- Heat flux and short wave radiation----------------------------------------!
!
     CALL BRACKET(HFX_TM,THOUR,L1,L2,FACT,UFACT,IERR)

     SPCP  = 4.2174E3_SP
     ROSEA = 1.023E3_SP
     SPRO  = SPCP*ROSEA

     IF(IERR==-1)THEN
       WTSURF = 0.0_SP
       SWRAD  = 0.0_SP
     ELSE
       WTSURF(1:M) = UFACT*DHFLUX(1:M,L1)  + FACT*DHFLUX(1:M,L2)
       SWRAD(1:M)  = UFACT*DHSHORT(1:M,L1) + FACT*DHSHORT(1:M,L2)
       WTSURF = -WTSURF/SPRO*RAMP
       SWRAD  = -SWRAD/SPRO*RAMP
     END IF


!
!--- Wind Stress for the Internal Mode-----------------------------------------!
!

     CALL BRACKET(WND_TM,THOUR,L1,L2,FACT,UFACT,IERR)

     IF(IERR == -1)THEN
       WUSURF = 0.0_SP
       WVSURF = 0.0_SP
     ELSE

     IF(WINDTYPE == 'speed')THEN
       DO I=1,N
         TX = UFACT*DTX(I,L1) + FACT*DTX(I,L2)
         TY = UFACT*DTY(I,L1) + FACT*DTY(I,L2)
         WDS=SQRT(TX*TX+TY*TY)
         CD=1.2E-3_SP
         IF (WDS >= 11.0_SP) CD=(0.49_SP+0.065_SP*WDS)*1.E-3_SP
         IF (WDS >= 25.0_SP) CD=(0.49_SP+0.065_SP*25.0_SP)*1.E-3_SP
         TX = 1.2_SP*CD*TX*WDS
         TY = 1.2_SP*CD*TY*WDS
         UUWIND(I)=-1.0E-3_SP*TX
         VVWIND(I)=-1.0E-3_SP*TY
         WUSURF(I)=-1.0E-3_SP*TX*RAMP
         WVSURF(I)=-1.0E-3_SP*TY*RAMP
       END DO
     ELSE IF(WINDTYPE == 'stress') THEN
       DO I=1,N
         TX = UFACT*DTX(I,L1) + FACT*DTX(I,L2)
         TY = UFACT*DTY(I,L1) + FACT*DTY(I,L2)
         TX = 0.001_SP*TX
         TY = 0.001_SP*TY
         UUWIND(I) = -TX
         VVWIND(I) = -TY
         WUSURF(I) = -TX*RAMP
         WVSURF(I) = -TY*RAMP
       END DO
     END IF
     END IF
#   if defined (MULTIPROCESSOR)
     IF(PAR) CALL EXCHANGE(EC,NT,1,MYID,NPROCS,UUWIND,VVWIND)
#      endif

   END IF !! MTYPE='non-uniform'

!==============================================================================|
   CASE(9) !External Mode Surface BCs (River Flux/Wind Stress/Heat/Moist)      !
!==============================================================================|
# if !defined (SEMI_IMPLICIT)
!
!-Freshwater Flux: Set  Based on Linear Interpolation Between Two Data Times---|
!

   IF (NUMQBC /= 0) THEN
     CALL BRACKET(QBC_TM,THOUR1,L1,L2,FACT,UFACT,IERR)
     QDIS2(:) = UFACT*DQDIS(:,L1) + FACT*DQDIS(:,L2)
     QDIS2    = QDIS2*RAMP
   END IF

!
!--Uniform Meteorology -> Set Precipitation/Evaporation/Surface Wind-----------|
!

   IF(M_TYPE == 'uniform') THEN

     CALL BRACKET(UMF_TM,THOUR1,L1,L2,FACT,UFACT,IERR)

     IF(IERR == -1)THEN
       QPREC2=0.0_SP
       QEVAP2=0.0_SP
       WUSURF2 = 0.0_SP
       WVSURF2 = 0.0_SP
     ELSE

       QPREC2 = UFACT*UQPREC(L1) + FACT*UQPREC(L2)
       QEVAP2 = UFACT*UQEVAP(L1) + FACT*UQEVAP(L2)
       QPREC2 = QPREC2*0.001_SP
       QEVAP2 = QEVAP2*0.001_SP

       TX = UFACT*UWIND(L1) + FACT*UWIND(L2)
       TY = UFACT*VWIND(L1) + FACT*VWIND(L2)

       IF(WINDTYPE == 'speed')THEN
         WDS=SQRT(TX*TX+TY*TY)
         CD=1.2E-3_SP
         IF (WDS >= 11.0_SP) CD=(0.49_SP+0.065_SP*WDS)*1.E-3_SP
         IF (WDS >= 25.0_SP) CD=(0.49_SP+0.065_SP*25.0_SP)*1.E-3_SP
         TX      = 1.2_SP*CD*TX*WDS
         TY      = 1.2_SP*CD*TY*WDS
         UUWIND  = 1.0E-3_SP*TX
         VVWIND  = 1.0E-3_SP*TY
         WUSURF2 = 1.0E-3_SP*TX*RAMP
         WVSURF2 = 1.0E-3_SP*TY*RAMP
       ELSE IF(WINDTYPE == 'stress')THEN
         TX      = 0.001_SP*TX
         TY      = 0.001_SP*TY
         UUWIND  = TX
         VVWIND  = TY
         WUSURF2 = TX*RAMP
         WVSURF2 = TY*RAMP
       END IF
       END IF

   END IF !!M_TYPE = 'uniform'

!
!--Non-Uniform Meteorology -> Set Precipitation/Evaporation/Surface Wind-------|
!

   IF(M_TYPE == 'non-uniform') THEN

     QPREC2=0.0_SP
     QEVAP2=0.0_SP
     IF(EVP_FLAG)THEN
       CALL BRACKET(EVP_TM,THOUR1,L1,L2,FACT,UFACT,IERR)
 
       IF(IERR /= -1)THEN
         QPREC2(1:M) = UFACT*DQPREC(1:M,L1) + FACT*DQPREC(1:M,L2)
         QEVAP2(1:M) = UFACT*DQEVAP(1:M,L1) + FACT*DQEVAP(1:M,L2)
       END IF
       QPREC2 = QPREC2*0.001_SP
       QEVAP2 = QEVAP2*0.001_SP
     END IF  

     CALL BRACKET(WND_TM,THOUR1,L1,L2,FACT,UFACT,IERR)

     IF(IERR == -1)THEN
       WUSURF2 = 0.0_SP
       WVSURF2 = 0.0_SP
     ELSE
     IF(WINDTYPE == 'speed') THEN
       DO I=1,N
         TX = UFACT*DTX(I,L1) + FACT*DTX(I,L2)
         TY = UFACT*DTY(I,L1) + FACT*DTY(I,L2)
         WDS=SQRT(TX*TX+TY*TY)
         CD=1.2E-3_SP
         IF (WDS >= 11.0_SP) CD=(0.49_SP+0.065_SP*WDS)*1.E-3_SP
         IF (WDS >= 25.0_SP) CD=(0.49_SP+0.065_SP*25.0_SP)*1.E-3_SP
         TX = 1.2_SP*CD*TX*WDS
         TY = 1.2_SP*CD*TY*WDS
         UUWIND(I)  = 1.0E-3_SP*TX
         VVWIND(I)  = 1.0E-3_SP*TY
         WUSURF2(I) = 1.0E-3_SP*TX*RAMP
         WVSURF2(I) = 1.0E-3_SP*TY*RAMP
       END DO

     ELSE IF(WINDTYPE == 'stress') THEN
       DO I=1,N
         TX = UFACT*DTX(I,L1) + FACT*DTX(I,L2)
         TY = UFACT*DTY(I,L1) + FACT*DTY(I,L2)
         TX = 0.001_SP*TX
         TY = 0.001_SP*TY
         UUWIND(I) = TX
         VVWIND(I) = TY
         WUSURF2(I) = TX*RAMP
         WVSURF2(I) = TY*RAMP
       END DO
     END IF
     END IF


   END IF !!MTYPE='non-uniform'
# endif

   END SELECT

   RETURN
   END SUBROUTINE BCOND_GCY
!==============================================================================|


