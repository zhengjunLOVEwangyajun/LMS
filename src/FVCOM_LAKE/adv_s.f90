!==============================================================================|
!   Calculate Advection and Horizontal Diffusion Terms for Salinity            |
!==============================================================================|

   SUBROUTINE ADV_S               

!------------------------------------------------------------------------------|

   USE ALL_VARS
   USE BCS
   USE MOD_OBCS
#  if defined (MULTIPROCESSOR)
   USE MOD_PAR
#  endif
#  if defined (WET_DRY)
   USE MOD_WD
#  endif
#  if defined (SPHERICAL)
   USE MOD_SPHERICAL
#  if defined (NORTHPOLE)
   USE MOD_NORTHPOLE
#  endif   
#  endif
#  if defined (SEMI_IMPLICIT)
   USE MOD_SEMI_IMPLICIT
#  endif
   IMPLICIT NONE
   REAL(SP), DIMENSION(0:MT,KB)     :: XFLUX,XFLUX_ADV
   REAL(SP), DIMENSION(0:MT)           :: PUPX,PUPY,PVPX,PVPY  
   REAL(SP), DIMENSION(0:MT)           :: PSPX,PSPY,PSPXD,PSPYD,VISCOFF
   REAL(SP), DIMENSION(3*(NT),KBM1) :: DTIJ 
   REAL(SP), DIMENSION(3*(NT),KBM1) :: UVN
   REAL(SP) :: UTMP,VTMP,SITAI,FFD,FF1,X11,Y11,X22,Y22,X33,Y33,TMP1,TMP2,XI,YI
   REAL(SP) :: DXA,DYA,DXB,DYB,FIJ1,FIJ2,UN
   REAL(SP) :: TXX,TYY,FXX,FYY,VISCOF,EXFLUX,TEMP,STPOINT
   REAL(SP) :: FACT,FM1
   INTEGER  :: I,I1,I2,IA,IB,J,J1,J2,K,JTMP,JJ,II
   REAL(SP) :: S1MIN, S1MAX, S2MIN, S2MAX
#  if defined (SPHERICAL)
   REAL(DP) :: TY,TXPI,TYPI
   REAL(DP) :: XTMP1,XTMP
   REAL(DP) :: X1_DP,Y1_DP,X2_DP,Y2_DP,XII,YII
   REAL(DP) :: X11_TMP,Y11_TMP,X33_TMP,Y33_TMP
#  if defined (NORTHPOLE)
   REAL(DP) :: VX1_TMP,VY1_TMP,VX2_TMP,VY2_TMP
   REAL(DP) :: TXPI_TMP,TYPI_TMP
#  endif
#  endif
#  if defined (SEMI_IMPLICIT)
   REAL(SP) :: UN1
   REAL(SP), DIMENSION(3*(NT),KBM1) :: UVN1
   REAL(SP), DIMENSION(3*(NT),KBM1) :: DTIJ1
#  endif
#  if defined (MPDATA)
   REAL(SP) :: SMIN,SMAX,XXXX
   REAL(SP), DIMENSION(0:MT,KB)     :: S1_S    !! temporary salinity in modified upwind
   REAL(SP), DIMENSION(0:MT,KB)     :: S1_SF   !! temporary salinity in modified upwind
   REAL(SP), DIMENSION(0:MT,KB)     :: WWWS     
   REAL(SP), DIMENSION(0:MT,KB)     :: WWWSF   
   REAL(SP), DIMENSION(0:MT)        :: DTWWWS  
   REAL(SP), DIMENSION(0:MT,KB)     :: ZZZFLUX !! temporary total flux in corrected part
   REAL(SP), DIMENSION(0:MT,KB)     :: BETA    !! temporary beta coefficient in corrected part
   REAL(SP), DIMENSION(0:MT,KB)     :: BETAIN  !! temporary beta coefficient in corrected part
   REAL(SP), DIMENSION(0:MT,KB)     :: BETAOUT !! temporary beta coefficient in corrected part
   REAL(SP), DIMENSION(0:MT,KB)     :: S1_FRESH    !! for source term which also bring mass volume
   INTEGER ITERA, NTERA
#  endif
!------------------------------------------------------------------------------!

   FACT = 0.0_SP
   FM1  = 1.0_SP
   IF(HORZMIX == 'closure') THEN
     FACT = 1.0_SP
     FM1  = 0.0_SP
   END IF
     
!
!--Initialize Fluxes-----------------------------------------------------------!
!
   XFLUX     = 0.0_SP
   XFLUX_ADV = 0.0_SP

!
!--Loop Over Control Volume Sub-Edges And Calculate Normal Velocity------------!
!
!!#  if !defined (WET_DRY)
   DO I=1,NCV
     I1=NTRG(I)
!     DTIJ(I)=DT1(I1)
     DO K=1,KBM1
       DTIJ(I,K) = DT1(I1)*DZ1(I1,K)
       UVN(I,K)  = V(I1,K)*DLTXE(I) - U(I1,K)*DLTYE(I)
#      if defined (SEMI_IMPLICIT)
       DTIJ1(I,K) = D1(I1)*DZ1(I1,K)
       UVN1(I,K) = VF(I1,K)*DLTXE(I) - UF(I1,K)*DLTYE(I)
#      endif
     END DO
   END DO
!!#  else
!!   DO I=1,NCV
!!     I1=NTRG(I)
!!!     DTIJ(I)=DT1(I1)
!!     DO K=1,KBM1
!!       DTIJ(I,K) = DT1(I1)*DZ1(I1,K)
!!       UVN(I,K) = VS(I1,K)*DLTXE(I) - US(I1,K)*DLTYE(I)
!!#      if defined (SEMI_IMPLICIT)
!!       DTIJ1(I,K) = D1(I1)*DZ1(I1,K)
!!       UVN1(I,K) = VF(I1,K)*DLTXE(I) - UF(I1,K)*DLTYE(I)
!!#      endif
!!     END DO
!!   END DO
!!#  endif

!
!--Calculate the Advection and Horizontal Diffusion Terms----------------------!
!

   DO K=1,KBM1
     PSPX  = 0.0_SP 
     PSPY  = 0.0_SP 
     PSPXD = 0.0_SP 
     PSPYD = 0.0_SP
     DO I=1,M
       DO J=1,NTSN(I)-1
         I1=NBSN(I,J)
         I2=NBSN(I,J+1)

#    if defined (WET_DRY)
         IF(ISWETN(I1) == 0 .AND. ISWETN(I2) == 1)THEN
          FFD=0.5_SP*(S1(I,K)+S1(I2,K)-SMEAN1(I,K)-SMEAN1(I2,K))
          FF1=0.5_SP*(S1(I,K)+S1(I2,K))
	 ELSE IF(ISWETN(I1) == 1 .AND. ISWETN(I2) == 0)THEN
          FFD=0.5_SP*(S1(I1,K)+S1(I,K)-SMEAN1(I1,K)-SMEAN1(I,K))
          FF1=0.5_SP*(S1(I1,K)+S1(I,K))
	 ELSE IF(ISWETN(I1) == 0 .AND. ISWETN(I2) == 0)THEN
          FFD=0.5_SP*(S1(I,K)+S1(I,K)-SMEAN1(I,K)-SMEAN1(I,K))
          FF1=0.5_SP*(S1(I,K)+S1(I,K))
	 ELSE
          FFD=0.5_SP*(S1(I1,K)+S1(I2,K)-SMEAN1(I1,K)-SMEAN1(I2,K))
          FF1=0.5_SP*(S1(I1,K)+S1(I2,K))
	 END IF 
#    else	 
         FFD=0.5_SP*(S1(I1,K)+S1(I2,K)-SMEAN1(I1,K)-SMEAN1(I2,K))
         FF1=0.5_SP*(S1(I1,K)+S1(I2,K))
#    endif	 
	 
#        if defined (SPHERICAL)
         XTMP  = VX(I2)*TPI-VX(I1)*TPI
         XTMP1 = VX(I2)-VX(I1)
         IF(XTMP1 >  180.0_SP)THEN
           XTMP = -360.0_SP*TPI+XTMP
         ELSE IF(XTMP1 < -180.0_SP)THEN
           XTMP =  360.0_SP*TPI+XTMP
         END IF  

!         TXPI=XTMP*COS(DEG2RAD*VY(I))
         TXPI=XTMP*VAL_COS_VY(I) 
         TYPI=(VY(I1)-VY(I2))*TPI
#    if defined (NORTHPOLE)
         IF(NODE_NORTHAREA(I) == 1)THEN
           VX1_TMP = REARTH * COS(VY(I1)*DEG2RAD) * COS(VX(I1)*DEG2RAD) &
                     * 2._SP /(1._SP+sin(VY(I1)*DEG2RAD))
           VY1_TMP = REARTH * COS(VY(I1)*DEG2RAD) * SIN(VX(I1)*DEG2RAD) &
                     * 2._SP /(1._SP+sin(VY(I1)*DEG2RAD))

           VX2_TMP = REARTH * COS(VY(I2)*DEG2RAD) * COS(VX(I2)*DEG2RAD) &
                     * 2._SP /(1._SP+sin(VY(I2)*DEG2RAD))
           VY2_TMP = REARTH * COS(VY(I2)*DEG2RAD) * SIN(VX(I2)*DEG2RAD) &
                     * 2._SP /(1._SP+sin(VY(I2)*DEG2RAD))

           TXPI = (VX2_TMP-VX1_TMP)/(2._SP /(1._SP+sin(VY(I)*DEG2RAD)))
           TYPI = (VY1_TMP-VY2_TMP)/(2._SP /(1._SP+sin(VY(I)*DEG2RAD)))
  	   IF(I /= NODE_NORTHPOLE)THEN
	     TXPI_TMP = TYPI*COS(VX(I)*DEG2RAD)-TXPI*SIN(VX(I)*DEG2RAD)
	     TYPI_TMP = TXPI*COS(VX(I)*DEG2RAD)+TYPI*SIN(VX(I)*DEG2RAD)
	     TYPI_TMP = -TYPI_TMP
	    
	     TXPI = TXPI_TMP
	     TYPI = TYPI_TMP
	   END IF  
	 END IF 
#    endif	 
         PSPX(I)=PSPX(I)+FF1*TYPI
         PSPY(I)=PSPY(I)+FF1*TXPI
         PSPXD(I)=PSPXD(I)+FFD*TYPI
         PSPYD(I)=PSPYD(I)+FFD*TXPI
#        else
         PSPX(I)=PSPX(I)+FF1*(VY(I1)-VY(I2))
         PSPY(I)=PSPY(I)+FF1*(VX(I2)-VX(I1))
         PSPXD(I)=PSPXD(I)+FFD*(VY(I1)-VY(I2))
         PSPYD(I)=PSPYD(I)+FFD*(VX(I2)-VX(I1))
#        endif
       END DO
       PSPX(I)=PSPX(I)/ART2(I)
       PSPY(I)=PSPY(I)/ART2(I)
       PSPXD(I)=PSPXD(I)/ART2(I)
       PSPYD(I)=PSPYD(I)/ART2(I)
     END DO
          
     IF(K == KBM1)THEN
       DO I=1,M
         PFPXB(I) = PSPX(I)
         PFPYB(I) = PSPY(I)
       END DO
     END IF

     DO I=1,M
       VISCOFF(I)=VISCOFH(I,K)
     END DO

     IF(K == KBM1) THEN
       AH_BOTTOM(1:M) = HORCON*(FACT*VISCOFF(1:M) + FM1)
     END IF


     DO I=1,NCV_I
       IA=NIEC(I,1)
       IB=NIEC(I,2)
       XI=0.5_SP*(XIJE(I,1)+XIJE(I,2))
       YI=0.5_SP*(YIJE(I,1)+YIJE(I,2))
#      if defined (SPHERICAL)
       X1_DP=XIJE(I,1)
       Y1_DP=YIJE(I,1)
       X2_DP=XIJE(I,2)
       Y2_DP=YIJE(I,2)

!       CALL ARCC(X2_DP,Y2_DP,X1_DP,Y1_DP,XII,YII)
!       XII=XCG2(I)
!       YII=YCG2(I)      

       XI=XCG2(I)
       XTMP  = XI*TPI-VX(IA)*TPI
       XTMP1 = XI-VX(IA)
       IF(XTMP1 >  180.0_SP)THEN
         XTMP = -360.0_SP*TPI+XTMP
       ELSE IF(XTMP1 < -180.0_SP)THEN
         XTMP =  360.0_SP*TPI+XTMP
       END IF

!       DXA=XTMP*COS(DEG2RAD*VY(IA))    
       DXA=XTMP*VAL_COS_VY(IA)
       DYA=(YI-VY(IA))*TPI
       XTMP  = XI*TPI-VX(IB)*TPI
       XTMP1 = XI-VX(IB)
       IF(XTMP1 >  180.0_SP)THEN
         XTMP = -360.0_SP*TPI+XTMP
       ELSE IF(XTMP1 < -180.0_SP)THEN
         XTMP =  360.0_SP*TPI+XTMP
       END IF

!       DXB=XTMP*COS(DEG2RAD*VY(IB)) 
       DXB=XTMP*VAL_COS_VY(IB)      
       DYB=(YI-VY(IB))*TPI
#      else
       DXA=XI-VX(IA)
       DYA=YI-VY(IA)
       DXB=XI-VX(IB)
       DYB=YI-VY(IB)
#      endif

       FIJ1=S1(IA,K)+DXA*PSPX(IA)+DYA*PSPY(IA)
       FIJ2=S1(IB,K)+DXB*PSPX(IB)+DYB*PSPY(IB)

       S1MIN=MINVAL(S1(NBSN(IA,1:NTSN(IA)-1),K))
       S1MIN=MIN(S1MIN, S1(IA,K))
       S1MAX=MAXVAL(S1(NBSN(IA,1:NTSN(IA)-1),K))
       S1MAX=MAX(S1MAX, S1(IA,K))
       S2MIN=MINVAL(S1(NBSN(IB,1:NTSN(IB)-1),K))
       S2MIN=MIN(S2MIN, S1(IB,K))
       S2MAX=MAXVAL(S1(NBSN(IB,1:NTSN(IB)-1),K))
       S2MAX=MAX(S2MAX, S1(IB,K))
       IF(FIJ1 < S1MIN) FIJ1=S1MIN
       IF(FIJ1 > S1MAX) FIJ1=S1MAX
       IF(FIJ2 < S2MIN) FIJ2=S2MIN
       IF(FIJ2 > S2MAX) FIJ2=S2MAX
    
       UN=UVN(I,K)
#      if defined (SEMI_IMPLICIT)
       UN1=UVN1(I,K)
#      endif

       VISCOF=HORCON*(FACT*(VISCOFF(IA)+VISCOFF(IB))*0.5_SP + FM1)

       TXX=0.5_SP*(PSPXD(IA)+PSPXD(IB))*VISCOF
       TYY=0.5_SP*(PSPYD(IA)+PSPYD(IB))*VISCOF

       FXX=-DTIJ(I,K)*TXX*DLTYE(I)
       FYY= DTIJ(I,K)*TYY*DLTXE(I)

#      if !defined (SEMI_IMPLICIT)
       EXFLUX=-UN*DTIJ(I,K)* &
          ((1.0_SP+SIGN(1.0_SP,UN))*FIJ2+(1.0_SP-SIGN(1.0_SP,UN))*FIJ1)*0.5_SP+FXX+FYY
#      else
       EXFLUX=-UN*DTIJ(I,K)* &
          ((1.0_SP+SIGN(1.0_SP,UN))*FIJ2+(1.0_SP-SIGN(1.0_SP,UN))*FIJ1)*0.5_SP
       EXFLUX=(1.0_SP-IFCETA)*EXFLUX+IFCETA*(-UN1*DTIJ1(I,K)*((1.0_SP+SIGN(1.0_SP,UN1))*FIJ2+(1.0_SP-SIGN(1.0_SP,UN1))*FIJ1)*0.5_SP)+FXX+FYY
#      endif

       XFLUX(IA,K)=XFLUX(IA,K)+EXFLUX
       XFLUX(IB,K)=XFLUX(IB,K)-EXFLUX

       XFLUX_ADV(IA,K)=XFLUX_ADV(IA,K)+(EXFLUX-FXX-FYY)
       XFLUX_ADV(IB,K)=XFLUX_ADV(IB,K)-(EXFLUX-FXX-FYY)
     END DO

#    if defined (SPHERICAL) && (NORTHPOLE)
#    if !defined (SEMI_IMPLICIT)
       CALL ADV_S_XY(XFLUX,XFLUX_ADV,PSPX,PSPY,PSPXD,PSPYD,VISCOFF,K,0.0_SP)
#    else
       CALL ADV_S_XY(XFLUX,XFLUX_ADV,PSPX,PSPY,PSPXD,PSPYD,VISCOFF,K,IFCETA)
#    endif
#    endif

   END DO !!SIGMA LOOP

!
!-Accumulate Fluxes at Boundary Nodes
!
# if defined (MULTIPROCESSOR)
   IF(PAR)CALL NODE_MATCH(0,NBN,BN_MLT,BN_LOC,BNC,MT,KB,MYID,NPROCS,XFLUX,XFLUX_ADV)
# endif

   DO K=1,KBM1
     IF(IOBCN > 0) THEN
       DO I=1,IOBCN
         I1=I_OBC_N(I)
         XFLUX_OBC(I,K)=XFLUX_ADV(I1,K)
       END DO
     END IF
   END DO


!--Set Boundary Conditions-For Fresh Water Flux--------------------------------!
!
# if defined (MPDATA)

!   S. HU
!   Using smolarkiewicz, P. K; A fully multidimensional positive definite advection
!   transport algorithm with small implicit diffusion, Journal of Computational
!   Physics, 54, 325-362, 1984
!-----------------------------------------------------------------

!-----combine all the horizontal flux first-----------------------------------

!-------fresh water part--------------

        S1_FRESH=S1


   IF(POINT_ST_TYPE == 'calculated') THEN
     IF(INFLOW_TYPE == 'node') THEN
       IF(NUMQBC > 0) THEN
         DO J=1,NUMQBC
           JJ=INODEQ(J)
           STPOINT=SDIS(J)
           DO K=1,KBM1
        S1_FRESH(JJ,K)=SDIS(J)
        XFLUX(JJ,K)=XFLUX(JJ,K) - QDIS(J)*VQDIST(J,K)*STPOINT    !/DZ(JJ,K)

          IF(QDIS(J) < 0 ) XFLUX(JJ,K)= -XFLUX(JJ,K)

           END DO
         END DO
       END IF
     ELSE IF(INFLOW_TYPE == 'edge') THEN
       IF(NUMQBC > 0) THEN
         DO J=1,NUMQBC
           J1=N_ICELLQ(J,1)
           J2=N_ICELLQ(J,2)
           STPOINT=SDIS(J) !!ASK LIU SHOULD THIS BE STPOINT1(J1)/STPOINT2(J2)
           DO K=1,KBM1
             S1_FRESH(J1,K)=SDIS(J)
             S1_FRESH(J1,K)=SDIS(J)
             XFLUX(J1,K)=XFLUX(J1,K)-  &
                         QDIS(J)*RDISQ(J,1)*VQDIST(J,K)*STPOINT    !/DZ(J1,K)
             XFLUX(J2,K)=XFLUX(J2,K)-  &
                         QDIS(J)*RDISQ(J,2)*VQDIST(J,K)*STPOINT    !/DZ(J2,K)
           END DO
         END DO
       END IF
     END IF
   END IF
!


! The horizontal term of advection is neglected here
   DO K=1,KBM1
     DO I=1,M
       IF(ISONB(I) == 2) THEN
         XFLUX(I,K)=0.
       ENDIF
     END DO
   END DO
   
! Initialize variables of MPDATA
   S1_S=0._SP
   S1_SF=0._SP
   WWWS=0._SP
   WWWSF=0._SP
   DTWWWS=0._SP
   ZZZFLUX=0._SP
   BETA=0._SP
   BETAIN=0._SP
   BETAOUT=0._SP

!!   first loop for vertical upwind
!!   flux including horizontal and vertical upwind
   DO K=1,KBM1
     DO I=1,M
#    if defined (WET_DRY)
       IF(ISWETN(I)*ISWETNT(I) == 1) THEN
#    endif
         IF(K == 1) THEN
           TEMP = -(WTS(I,K+1)-ABS(WTS(I,K+1)))*S1(I,K)   &
                  -(WTS(I,K+1)+ABS(WTS(I,K+1)))*S1(I,K+1) &
                  +(WTS(I,K)+ABS(WTS(I,K)))*S1(I,K)    
         ELSE IF(K == KBM1) THEN
           TEMP = +(WTS(I,K)-ABS(WTS(I,K)))*S1(I,K-1)     &
                  +(WTS(I,K)+ABS(WTS(I,K)))*S1(I,K)
         ELSE
           TEMP = -(WTS(I,K+1)-ABS(WTS(I,K+1)))*S1(I,K)   &
                  -(WTS(I,K+1)+ABS(WTS(I,K+1)))*S1(I,K+1) &
                  +(WTS(I,K)-ABS(WTS(I,K)))*S1(I,K-1)     &
                  +(WTS(I,K)+ABS(WTS(I,K)))*S1(I,K)
         END IF
         TEMP = 0.5_SP*TEMP 

         IF(K == 1)THEN
           SMAX = MAXVAL(S1(NBSN(I,1:NTSN(I)),K))
           SMIN = MINVAL(S1(NBSN(I,1:NTSN(I)),K))
           SMAX = MAX(SMAX,S1(I,K+1),S1(I,K),S1_FRESH(I,K))
           SMIN = MIN(SMIN,S1(I,K+1),S1(I,K),S1_FRESH(I,K))
         ELSEIF(K == KBM1) THEN
           SMAX = MAXVAL(S1(NBSN(I,1:NTSN(I)),K))
           SMIN = MINVAL(S1(NBSN(I,1:NTSN(I)),K))
           SMAX = MAX(SMAX,S1(I,K-1),S1(I,K),S1_FRESH(I,K))
           SMIN = MIN(SMIN,S1(I,K-1),S1(I,K),S1_FRESH(I,K))
         ELSE
           SMAX = MAXVAL(S1(NBSN(I,1:NTSN(I)),K))
           SMIN = MINVAL(S1(NBSN(I,1:NTSN(I)),K))
           SMAX = MAX(SMAX,S1(I,K+1),S1(I,K-1),S1(I,K),S1_FRESH(I,K))
           SMIN = MIN(SMIN,S1(I,K+1),S1(I,K-1),S1(I,K),S1_FRESH(I,K))
         END IF


         ZZZFLUX(I,K) = TEMP*(DTI/DT(I))/DZ(I,K) + XFLUX(I,K)/ART1(I)*(DTI/DT(I))/DZ(I,K) 
         XXXX = ZZZFLUX(I,K)*DT(I)/DTFA(I)+S1(I,K)-S1(I,K)*DT(I)/DTFA(I) 

         BETA(I,K)=0.5*(1.-SIGN(1.,XXXX)) * (SMAX-S1(I,K))/(ABS(XXXX)+1.E-10) &
                  +0.5*(1.-SIGN(1.,-XXXX)) * (S1(I,K)-SMIN)/(ABS(XXXX)+1.E-10)

         S1_SF(I,K)=S1(I,K)-MIN(1.,BETA(I,K))*XXXX

#    if defined (WET_DRY)
       END IF
#    endif
     END DO
   END DO  !! SIGMA LOOP

!----------------------------------------------------------------------------------------
   NTERA = 4
   DO ITERA=1,NTERA   !! Smolaricizw Loop 
     IF(ITERA == 1)THEN
       WWWSF  = WTS
       S1_S   = S1_SF
       DTWWWS = DT
     ELSE
       WWWSF  = WWWS
       S1_S   = S1_SF
       DTWWWS = DTFA
     END IF
     DO K=2,KBM1
       DO I=1,M
         TEMP=ABS(WWWSF(I,K))-DTI*(WWWSF(I,K))*(WWWSF(I,K))/DZ(I,K)/DTWWWS(I)
         WWWS(I,K)=TEMP*(S1_S(I,K-1)-S1_S(I,K))/(ABS(S1_S(I,K-1))+ABS(S1_S(I,K))+1.E-14)
 
         IF(TEMP < 0.0_SP .OR. S1_S(I,K) == 0.0_SP)THEN 
           WWWS(I,K)=0. 
         END IF
       END DO 
     END DO
     DO I=1,M
       WWWS(I,1)=0.
     END DO

     DO I=1,M
       SMAX = MAXVAL(S1(NBSN(I,1:NTSN(I)),1))
       SMIN = MINVAL(S1(NBSN(I,1:NTSN(I)),1))
       SMAX = MAX(SMAX,S1(I,2),S1(I,1),S1_FRESH(I,1))
       SMIN = MIN(SMIN,S1(I,2),S1(I,1),S1_FRESH(I,1))
 
       TEMP=0.5*((WWWS(I,2)+ABS(WWWS(I,2)))*S1_S(I,2))*(DTI/DTFA(I))/DZ(I,1)
       BETAIN(I,1)=(SMAX-S1_S(I,1))/(TEMP+1.E-10)

       TEMP=0.5*((WWWS(I,1)+ABS(WWWS(I,1)))*S1_S(I,1)-        &
	           (WWWS(I,2)-ABS(WWWS(I,2)))*S1_S(I,1))*(DTI/DTFA(I))/DZ(I,1)
       BETAOUT(I,1)=(S1_S(I,1)-SMIN)/(TEMP+1.E-10)

       WWWSF(I,1)=0.5*MIN(1.,BETAOUT(I,1))*(WWWS(I,1)+ABS(WWWS(I,1))) + &
                    0.5*MIN(1.,BETAIN(I,1))*(WWWS(I,1)-ABS(WWWS(I,1)))
     END DO

     DO K=2,KBM1-1
       DO I=1,M
         SMAX = MAXVAL(S1(NBSN(I,1:NTSN(I)),K))
         SMIN = MINVAL(S1(NBSN(I,1:NTSN(I)),K))
         SMAX = MAX(SMAX,S1(I,K+1),S1(I,K-1),S1(I,K),S1_FRESH(I,K))
         SMIN = MIN(SMIN,S1(I,K+1),S1(I,K-1),S1(I,K),S1_FRESH(I,K))
 
         TEMP=0.5*((WWWS(I,K+1)+ABS(WWWS(I,K+1)))*S1_S(I,K+1)-  &
	           (WWWS(I,K)-ABS(WWWS(I,K)))*S1_S(I,K-1))*(DTI/DTFA(I))/DZ(I,K)
         BETAIN(I,K)=(SMAX-S1_S(I,K))/(TEMP+1.E-10)

         TEMP=0.5*((WWWS(I,K)+ABS(WWWS(I,K)))*S1_S(I,K)-        &
	           (WWWS(I,K+1)-ABS(WWWS(I,K+1)))*S1_S(I,K))*(DTI/DTFA(I))/DZ(I,K)
         BETAOUT(I,K)=(S1_S(I,K)-SMIN)/(TEMP+1.E-10)

         WWWSF(I,K)=0.5*MIN(1.,BETAIN(I,K-1),BETAOUT(I,K))*(WWWS(I,K)+ABS(WWWS(I,K))) + &
                    0.5*MIN(1.,BETAIN(I,K),BETAOUT(I,K-1))*(WWWS(I,K)-ABS(WWWS(I,K)))
       END DO
     END DO


     K=KBM1
       DO I=1,M
         SMAX = MAXVAL(S1(NBSN(I,1:NTSN(I)),K))
         SMIN = MINVAL(S1(NBSN(I,1:NTSN(I)),K))
         SMAX = MAX(SMAX,S1(I,K-1),S1(I,K),S1_FRESH(I,K))
         SMIN = MIN(SMIN,S1(I,K-1),S1(I,K),S1_FRESH(I,K))
 
         TEMP=0.5*((WWWS(I,K+1)+ABS(WWWS(I,K+1)))*S1_S(I,K+1)-  &
	           (WWWS(I,K)-ABS(WWWS(I,K)))*S1_S(I,K-1))*(DTI/DTFA(I))/DZ(I,K)
         BETAIN(I,K)=(SMAX-S1_S(I,K))/(TEMP+1.E-10)

         TEMP=0.5*((WWWS(I,K)+ABS(WWWS(I,K)))*S1_S(I,K)-        &
	           (WWWS(I,K+1)-ABS(WWWS(I,K+1)))*S1_S(I,K))*(DTI/DTFA(I))/DZ(I,K)
         BETAOUT(I,K)=(S1_S(I,K)-SMIN)/(TEMP+1.E-10)

         WWWSF(I,K)=0.5*MIN(1.,BETAIN(I,K-1),BETAOUT(I,K))*(WWWS(I,K)+ABS(WWWS(I,K))) + &
                    0.5*MIN(1.,BETAIN(I,K),BETAOUT(I,K-1))*(WWWS(I,K)-ABS(WWWS(I,K)))
       END DO
     

     WWWS=WWWSF 

     DO K=1,KBM1
       DO I=1,M
#      if defined (WET_DRY)
         IF(ISWETN(I)*ISWETNT(I) == 1) THEN
#      endif
           IF(K == 1) THEN
             TEMP = -(WWWS(I,K+1)-ABS(WWWS(I,K+1)))*S1_S(I,K)   &
                    -(WWWS(I,K+1)+ABS(WWWS(I,K+1)))*S1_S(I,K+1) &
                    +(WWWS(I,K)+ABS(WWWS(I,K)))*S1_S(I,K)
           ELSE IF(K == KBM1) THEN
             TEMP = +(WWWS(I,K)-ABS(WWWS(I,K)))*S1_S(I,K-1)     &
                    +(WWWS(I,K)+ABS(WWWS(I,K)))*S1_S(I,K)
           ELSE
             TEMP = -(WWWS(I,K+1)-ABS(WWWS(I,K+1)))*S1_S(I,K)   &
                    -(WWWS(I,K+1)+ABS(WWWS(I,K+1)))*S1_S(I,K+1) &
                    +(WWWS(I,K)-ABS(WWWS(I,K)))*S1_S(I,K-1)     &
                    +(WWWS(I,K)+ABS(WWWS(I,K)))*S1_S(I,K)
           END IF
           TEMP = 0.5_SP*TEMP
           S1_SF(I,K)=(S1_S(I,K)-TEMP*(DTI/DTFA(I))/DZ(I,K)) 
#      if defined (WET_DRY)
         END IF
#      endif
       END DO
     END DO  !! SIGMA LOOP
   END DO  !! Smolarvizw Loop
!--------------------------------------------------------------------------
! End of smolarkiewicz upwind loop
!--------------------------------------------------------------------------
#  endif


# if ! defined(MPDATA)
# if defined (ONE_D_MODEL)
    XFLUX = 0.0_SP
# endif    

!--------------------------------------------------------------------
!   The central difference scheme in vertical advection
!--------------------------------------------------------------------
   DO K=1,KBM1
     DO I=1,M
#    if defined (WET_DRY)
       IF(ISWETN(I)*ISWETNT(I) == 1) THEN
#    endif
       IF(K == 1) THEN
         TEMP=-WTS(I,K+1)*(S1(I,K)*DZ(I,K+1)+S1(I,K+1)*DZ(I,K))/   &
              (DZ(I,K)+DZ(I,K+1))
       ELSE IF(K == KBM1) THEN
         TEMP= WTS(I,K)*(S1(I,K)*DZ(I,K-1)+S1(I,K-1)*DZ(I,K))/(DZ(I,K)+DZ(I,K-1))
       ELSE
         TEMP= WTS(I,K)*(S1(I,K)*DZ(I,K-1)+S1(I,K-1)*DZ(I,K))/(DZ(I,K)+DZ(I,K-1))-&
               WTS(I,K+1)*(S1(I,K)*DZ(I,K+1)+S1(I,K+1)*DZ(I,K))/(DZ(I,K)+DZ(I,K+1))
       END IF

       IF(ISONB(I) == 2) THEN
!         XFLUX(I,K)=TEMP*ART1(I)/DZ(I,K)
         XFLUX(I,K)=TEMP*ART1(I)
       ELSE
!         XFLUX(I,K)=XFLUX(I,K)+TEMP*ART1(I)/DZ(I,K)
         XFLUX(I,K)=XFLUX(I,K)+TEMP*ART1(I)
       END IF
#    if defined (WET_DRY)
       END IF
#    endif
     END DO
   END DO  !! SIGMA LOOP

!
!--Set Boundary Conditions-For Fresh Water Flux--------------------------------!
!
   IF(POINT_ST_TYPE == 'calculated') THEN
     IF(INFLOW_TYPE == 'node') THEN
       IF(NUMQBC > 0) THEN
         DO J=1,NUMQBC
           JJ=INODEQ(J)
           STPOINT=SDIS(J)
           DO K=1,KBM1
!             XFLUX(JJ,K)=XFLUX(JJ,K) - QDIS(J)*VQDIST(J,K)*STPOINT/DZ(JJ,K)
            XFLUX(JJ,K)=XFLUX(JJ,K) - QDIS(J)*VQDIST(J,K)*STPOINT

            IF(QDIS(J) < 0 ) XFLUX(JJ,K)= -XFLUX(JJ,K)

           END DO
         END DO
       END IF
     ELSE IF(INFLOW_TYPE == 'edge') THEN
       IF(NUMQBC > 0) THEN
         DO J=1,NUMQBC
           J1=N_ICELLQ(J,1)
           J2=N_ICELLQ(J,2)
           STPOINT=SDIS(J) !!ASK LIU SHOULD THIS BE STPOINT1(J1)/STPOINT2(J2)
           DO K=1,KBM1
!             XFLUX(J1,K)=XFLUX(J1,K)-   &
!                         QDIS(J)*RDISQ(J,1)*VQDIST(J,K)*STPOINT/DZ(J1,K)
!             XFLUX(J2,K)=XFLUX(J2,K)-   &
!                         QDIS(J)*RDISQ(J,2)*VQDIST(J,K)*STPOINT/DZ(J2,K)
             XFLUX(J1,K)=XFLUX(J1,K)-QDIS(J)*RDISQ(J,1)*VQDIST(J,K)*STPOINT
             XFLUX(J2,K)=XFLUX(J2,K)-QDIS(J)*RDISQ(J,2)*VQDIST(J,K)*STPOINT
           END DO
         END DO
       END IF
     END IF
   END IF

# endif
!------------- the salinity flux from ground water ----------------------
   IF(IBFW > 0)THEN
     DO I=1,M
       DO J=1,IBFW
         IF(I == NODE_BFW(J))THEN
           XFLUX(I,KBM1)=XFLUX(I,KBM1)-BFWDIS3(J)*BFWSDIS3(J)    !/DZ(I,KBM1)
         END IF
       END DO
     END DO
   END IF

!--Update Salinity-------------------------------------------------------------!
!

   DO I=1,M
#  if defined (WET_DRY)
     IF(ISWETN(I)*ISWETNT(I) == 1 )THEN
#  endif
     DO K=1,KBM1
#    if !defined (MPDATA)     
!       SF1(I,K)=(S1(I,K)-XFLUX(I,K)/ART1(I)*(DTI/DT(I)))*(DT(I)/DTFA(I))
       SF1(I,K)=(S1(I,K)-XFLUX(I,K)/ART1(I)*(DTI/(DT(I)*DZ(I,K))))*(DT(I)/DTFA(I))
#    else
       SF1(I,K)=S1_SF(I,K)
#    endif              
     END DO
#  if defined (WET_DRY)
     ELSE
     DO K=1,KBM1
       SF1(I,K)=S1(I,K)
     END DO
     END IF
#  endif
   END DO

   RETURN
   END SUBROUTINE ADV_S
!==============================================================================|
