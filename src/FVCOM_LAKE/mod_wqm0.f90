﻿MODULE MOD_WQM
#  if defined (WATER_QUALITY)
   USE MOD_PREC
   IMPLICIT NONE
   SAVE

 
   INTEGER NB
   INTEGER, PARAMETER :: INRIVW = 61   !!UNIT NUMBER FOR WQ RIVER INPUT DATA

   REAL(SP), PARAMETER :: DAY_SEC = 24*3600.0_SP
   REAL(SP), PARAMETER :: TCE2 = 1.20_SP
   REAL(SP), PARAMETER :: TCS2 = 1.15_SP

   REAL(SP) :: K_DEOX      !!Deoxygenation rate at 20 degree, 0.16-0.21, (day^-1);
   REAL(SP) :: K_NITR      !!Nitrification rate at 20 degree, 0.09-0.13, (day^-1);
   REAL(SP) :: K_RESP      !!Phytoplankton respiration rate at 20 degree, (day^-1);
   REAL(SP) :: K_RESP1     !!Bacterial respiration rate, 0.8 (uM/h);
   REAL(SP) :: K_DENI      !!Denitrification rate at 20 degree, (day^-1);
   REAL(SP) :: K_GROW      !!Optimum phytoplankton growth rate at 20 degree, (day^-1);
   REAL(SP) :: K_MORT      !!The Mortality rate of phytoplankton at 20 degree, (day^-1);
   REAL(SP) :: K_mine1     !!Organic nitrogen mineralization at 20 degree, (day^-1);
   REAL(SP) :: K_mine2     !!Organic phosphorus mineralization at 20 degree, (day^-1);
   REAL(SP) :: Temp_reae   !!Temperature coefficient of reaeration;
   REAL(SP) :: Temp_deox   !!Temperature coefficient of deoxygenation;
   REAL(SP) :: Temp_nitr   !!Temperature coefficient of nitrification;
   REAL(SP) :: Temp_resp   !!Temperature coefficient of phytoplankton respiration;
   REAL(SP) :: Temp_deni   !!Temperature coefficient of denitrification, 1.045-1.08;
   REAL(SP) :: Temp_grow   !!Temperature coefficient of optimum growth;
   REAL(SP) :: Temp_mort   !!Temperature coefficient of phytoplankton mortality;
   REAL(SP) :: Temp_mine1  !!Temperature coefficient of nitrogen mineralization;
   REAL(SP) :: Temp_mine2  !!Temperature coefficient of phosphorus mineralization;
   REAL(SP) :: Temp_sod    !!Temperature coefficient of SOD;
   REAL(SP) :: KBOD        !!Half-saturation constant for oxygen limitation, (mg O2/l);
   REAL(SP) :: KNITR       !!Half-saturation constant for oxygen limitation, (mg O2/l);
   REAL(SP) :: KmN         !!Half-saturation constant for uptake of inorganic nitrogen, (ug N/l);
   REAL(SP) :: KmP         !!Half-saturation constant for uptake of inorganic phosphorus, (ug P/l);
   REAL(SP) :: KNO3        !!Half-saturation constant for oxygen limitation, (mg O2/l);
   REAL(SP) :: KmPC        !!Half-saturation constant of phytoplankton limitation of phosphorus recycle, (mg C/l);
   REAL(SP) :: SOD         !!Sediment Oxygen Demand at 20 degree, 0.2-0.4, (g/m^2.day);
   REAL(SP) :: WSS2        !!Organic matter sinking velocity, (m/day);
   REAL(SP) :: WSS3        !!Phytoplankton settling velocity, (m/day);
   REAL(SP) :: FD2         !!Fraction of dissolved CBOD;
   REAL(SP) :: FD6         !!Fraction of dissolved organic nitrogen;
   REAL(SP) :: FD8         !!Fraction of dissolved organic phosphorus;
   REAL(SP) :: FON         !!Fraction of dead and respired phytoplankton recycled to the organic nitorgen pool;
   REAL(SP) :: FOP         !!Fraction of dead and respired phytoplankton recycled to the organic phosphorus pool;
   REAL(SP) :: Time_U      !!Time (in hour) of sunrise;
   REAL(SP) :: Time_D      !!Time (in hour) of sunset;
   REAL(SP) :: Solar_S     !!Optimum solar radiation rate, (langleys/day);
   REAL(SP) :: Solar_A     !!Total daily solar radiation, (langleys/day);
   REAL(SP) :: Ratio_NC    !!Ratio of nitrogen to carbon in phytoplankton, 16/106 by Redfield ratio, (mg N/mg C); 
   REAL(SP) :: Ratio_PC    !!Ratio of phosphorus to carbon in phytoplankton,1/106 by Redfield ratio, (mg P/mg C);
   REAL(SP) :: Rsed_NH4    !!
   REAL(SP) :: Rsed_NO3    !!
   REAL(SP) :: Rsed_OP4    !!

   REAL(SP) :: KB_ds       !!Organic Carbon (as CBOD) decomposition rate at 20 degree, (day^-1);
   REAL(SP) :: KB_pzd      !!Anaerobic algal decomposition rate at 20 degree, (day^-1); 
   REAL(SP) :: KB_deni     !!Denitrification rate at 20 degree, (day^-1);
   REAL(SP) :: KB_ond      !!Organic nitrogen decomposition rate at 20 degree, (day^-1);
   REAL(SP) :: KB_opd      !!Organic phosphorus decomposition rate at 20 degree, (day^-1);
   REAL(SP) :: TempB_ds    !!Temperature coefficient of organic carbon decomposition;
   REAL(SP) :: TempB_pzd   !!Temperature coefficient of anaerobic algal decomposition;
   REAL(SP) :: TempB_deni  !!Temperature coefficient of denitrification;
   REAL(SP) :: TempB_ond   !!Temperature coefficient of organic nitrogen decomposition;
   REAL(SP) :: TempB_opd   !!Temperature coefficient of organic phosphorus decomposition;
   REAL(SP) :: Diff_z      !!Diffusive exchange coefficient, (m^2/day);
   REAL(SP) :: Dep_ben     !!Benthic layer depth, (m);
   REAL(SP) :: FDB2        !!Fraction of dissolved CBOD in sediment;
   REAL(SP) :: FDB4        !!Fraction of dissolved NH3 in sediment;
   REAL(SP) :: FDB5        !!Fraction of dissolved NO3 in sediment;
   REAL(SP) :: FDB6        !!Fraction of dissolved ON in sediment;
   REAL(SP) :: FDB7        !!Fraction of dissolved OPO4 in sediment;
   REAL(SP) :: FDB8        !!Fraction of dissolved OP in sediment;
   REAL(SP) :: FBON        !!Fraction of dead and respired phytoplankton recycled to the organic nitorgen pool;
   REAL(SP) :: FBOP        !!Fraction of dead and respired phytoplankton recycled to the organic phosphorus pool;
   REAL(SP) :: RatioB_NC   !!Ratio of nitrogen to carbon, (mg N/mg C);
   REAL(SP) :: RatioB_PC   !!Ratio of phosphorus to carbon, (mg P/mg C);

!   INTEGER  :: iurun1,iuprt1,iuprt2
   LOGICAL  :: BENWQM_KEY
   REAL(SP) :: time_r,TA
   REAL(SP), ALLOCATABLE :: CS(:,:)      !!DO saturation concentration, mg O2/l
   REAL(SP), ALLOCATABLE :: K_REAE(:,:)  !!Reaeration rate at 20 degree, day^-1
   REAL(SP), ALLOCATABLE :: PNH3G(:,:)   !!Ammonia preference
   REAL(SP), ALLOCATABLE :: RNUTR(:,:)   !!Growth rate reduction due to nutrient limitation
   REAL(SP), ALLOCATABLE :: RLIGHT(:,:)  !!Growth rate reduction due to light conditions
   REAL(SP), ALLOCATABLE :: GPP(:,:)     !!Phytoplankton growth rate
   REAL(SP), ALLOCATABLE :: DPP(:,:)     !!Phytoplankton loss rate
   REAL(SP), ALLOCATABLE :: SODD(:,:)    !!Sediment oxygen demand rate
   REAL(SP), ALLOCATABLE :: K_RESPP(:)   !!Bacterial respiration rate
   REAL(SP), ALLOCATABLE :: F_ONN(:)
   REAL(SP), ALLOCATABLE :: F_OPP(:)
   REAL(SP), ALLOCATABLE :: K_NITRR(:,:) !!Nitrification rate
   REAL(SP), ALLOCATABLE :: RSED1(:)     !!Nutrients released from sediment
   REAL(SP), ALLOCATABLE :: RSED2(:)     !!Nutrients released from sediment
   REAL(SP), ALLOCATABLE :: RSED3(:)     !!Nutrients released from sediment
   REAL(SP), ALLOCATABLE :: WQM(:,:,:)
   REAL(SP), ALLOCATABLE :: WQM_T(:,:,:)
   REAL(SP), ALLOCATABLE :: WQM_F(:,:,:)
   REAL(SP), ALLOCATABLE :: SEDWQM(:,:)
   REAL(SP), ALLOCATABLE :: WMEAN(:,:,:)
   REAL(SP), ALLOCATABLE :: WWSURF(:,:)

   REAL(SP), ALLOCATABLE :: DWDIS(:,:,:)  !!WATER QUALITY DISCHARGE DATA
   REAL(SP), ALLOCATABLE :: WDIS(:,:)     !!FRESH WATER QUALITY AT CURRENT TIME
   LOGICAL WQM_ON          !!TRUE IF WATER QUALITY MODEL ACTIVATED

   CONTAINS !------------------------------------------------------------------!
            ! GET_WQMPAR    :  Read WQM Control Parameters for ***_inp.dat     !
            ! WQMPARA       :  Read WQM Parameters from WQM Input Files        !
            ! ALLOC_WQM_VARS: Allocate Water Quality Model Variables           !
            ! INITIAL_WQM   : Initialize Water Quality Model Variables         !
            ! BCS_FORCE_WQM : Read In WQM Forcing (WQM Variable River Input)   !
            ! ADV_WQM       : Horizontal Advection/Diffusion of WQM Variables  !
            ! BCOND_WQM     : Boundary Conditions (River Flux) of WQM Variables!
            ! VDIF_WQM      : Vertical Diffusion of WQM Variables              !
            ! EXCHANGE_WQM  : Exchange Water Quality Variables among Processors!
            ! WQMCONST      : Calculate Coefficients used in WQM               !
            ! KAHYDRA       : Empirical Relation for Oxygen Aeration (By Flow) !
            ! KAWIND        : Empirical Relation for Oxygen Aeration (By Wind) !
            ! -----------------------------------------------------------------!
                                                                                                                            
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

!=============================================================================!
!    Input Parameters Which Control the Water Quality Model Run               !
!=============================================================================!

   SUBROUTINE GET_WQMPAR
   USE MOD_UTILS
   USE CONTROL
   USE MOD_INP
   IMPLICIT NONE
   
   INTEGER ISCAN
   CHARACTER(LEN=120) :: FNAME

!=============================================================================!
!       READ IN VARIABLES AND SET VALUES FOR WATER QUALITY                    ! 
!=============================================================================!

   FNAME = "./"//trim(casename)//"_run.dat"

!------------------------------------------------------------------------------|
!   CURRENT ASSIMILATION FLAG
!------------------------------------------------------------------------------|
   ISCAN = SCAN_FILE(TRIM(FNAME),"WQM_ON",LVAL = WQM_ON)
   IF(ISCAN /= 0)THEN
     WRITE(IPT,*)'ERROR READING WQM_ON: ',ISCAN
     IF(ISCAN == -2)THEN
       WRITE(IPT,*)'VARIABLE NOT FOUND IN INPUT FILE: ',TRIM(FNAME)
     END IF
     CALL PSTOP
   END IF

   IF(WQM_ON)THEN
!-----------------------------------------------------------------------------!
!       "N1" - NUMBER OF VARIABLES OF WATER QUALITY                           !
!-----------------------------------------------------------------------------!

   ISCAN = SCAN_FILE(TRIM(FNAME),"NB",ISCAL = NB)
   IF(ISCAN /= 0) THEN
     WRITE(*,*) 'ERROR READING NB: ',ISCAN
     CALL PSTOP
   END IF

!-----------------------------------------------------------------------------!
!      "BENWQM_KEY" - LOGICAL VALUE                                           !
!      IF BENWQM_KEY = TRUE,  BENTHIC WATER QUALITY VARIABLES INCLUDED        !
!      IF BENWQM_KEY = FALSE, NO BENTHIC WATER QUALITY VARIABLES INCLUDED     !
!-----------------------------------------------------------------------------!

   ISCAN = SCAN_FILE(TRIM(FNAME),"BENWQM_KEY",LVAL = BENWQM_KEY)
   IF(ISCAN /= 0) THEN
     WRITE(*,*) 'ERROR READING BENWQM_KEY: ',ISCAN
     CALL PSTOP
   END IF

   END IF
!-----------------------------------------------------------------------------! 
!  Call Water Quality Parameters
!-----------------------------------------------------------------------------!
   IF(WQM_ON) CALL WQMPARA

!-----------------------------------------------------------------------------! 
!  Report Water Quality Control Variables
!-----------------------------------------------------------------------------!
   IF(WQM_ON)THEN
     WRITE(IPT,*)'!  # WATER QUALITY MODEL :  ACTIVE'
     WRITE(IPT,*)'!  # WQM VARIABLES       :',NB     
     IF(BENWQM_KEY)THEN
       WRITE(IPT,*)'!  # BENTHIC VARIABLES   :  INCLUDED'
     ELSE
       WRITE(IPT,*)'!  # BENTHIC VARIABLES   :  NOT INCLUDED'
     END IF
   ELSE
     WRITE(IPT,*)'!  # WATER QUALITY MODEL :  NOT ACTIVE'
   END IF


   RETURN
   END SUBROUTINE GET_WQMPAR
!=============================================================================!

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

!=============================================================================!
   SUBROUTINE WQMPARA
!=============================================================================!
!									      !
!   This subroutine provides values of all parameters used in 		      !
!   the conventional eutrophication water quality model in   		      !
!   the Satilla River, Georgia. The water quality model in 		      !
!   the Satilla River includes eight variables. They are:		      !
!     (1) Dissolved Oxygen (DO), mg O2/l;				      !
!     (2) Carbonaceous Biochemical Oxygen Demand (CBOD), mg C/l;	      !
!     (3) Phytoplankton (PHYT), mg C/l;					      !
!     (4) Ammonia Nitrogen (NH3), mg N/l;				      !
!     (5) Nitrate Nitrogen (NO3), mg N/l; 				      !
!     (6) Organic Nitrogen (ON), mg N/l;				      !
!     (7) Orthophosphorus (or Inorganic Phosphorus, OPO4), mg P/l;	      !
!     (8) Organic Phosphorus (OP), mg P/l.				      !
!									      !
!   The water quality model was separated into water column and sediment      !
!   two layers. At the sediment layer, due to anaerobic condition, no         !
!   phytoplankton variable available.					      !
!									      !
!   This code is origionaly written by L. Zheng in March, 2000 for ECOM,      !
!   and rewriten by J. Qi for FVCOM in 2002 and 2004.			      !
!=============================================================================!

!-------------------------------------------------------------------------
!  The definition for each parameter in water column is:
!
!  K_deox:    Deoxygenation rate at 20 degree, 0.16-0.21, (day^-1);
!  K_nitr:    Nitrification rate at 20 degree, 0.09-0.13, (day^-1);
!  K_resp:    Phytoplankton respiration rate at 20 degree, (day^-1);
!  K_resp1:   Bacterial respiration rate, 0.8 (uM/h);
!  K_deni:    Denitrification rate at 20 degree, (day^-1);
!  K_grow:    Optimum phytoplankton growth rate at 20 degree, (day^-1);
!  K_mort:    The Mortality rate of phytoplankton at 20 degree, (day^-1);
!  K_mine1:   Organic nitrogen mineralization at 20 degree, (day^-1);
!  K_mine2:   Organic phosphorus mineralization at 20 degree, (day^-1);

!  KBOD:      Half-saturation constant for oxygen limitation, (mg O2/l);
!  KNITR:     Half-saturation concentration for oxygen limitation of nitriﬁcation, (mg O2/l);
!  KNO3:      Half-saturation concentration for oxygen limitation of denitriﬁcation , (mg O2/l);
!  KmN:       Half-saturation constant for uptake of inorganic 
!                nitrogen, (ug N/l);
!  KmP:       Half-saturation constant for uptake of inorganic 
!                phosphorus, (ug P/l);
!  KmPC:      Half-saturation constant of phytoplankton limitation of
!                phosphorus recycle, (mg C/l);

!  Temp_reae: Temperature coefficient of reaeration;
!  Temp_deox: Temperature coefficient of deoxygenation;
!  Temp_nitr: Temperature coefficient of nitrification;
!  Temp_resp: Temperature coefficient of phytoplankton respiration;
!  Temp_deni: Temperature coefficient of denitrification, 1.045-1.08;
!  Temp_grow: Temperature coefficient of optimum growth;
!  Temp_mort: Temperature coefficient of phytoplankton mortality;
!  Temp_mine1:Temperature coefficient of nitrogen mineralization;
!  Temp_mine2:Temperature coefficient of phosphorus mineralization;
!  Temp_sod:  Temperature coefficient of SOD;

!  SOD:       Sediment Oxygen Demand at 20 degree, 0.2-0.4, (g/m^2.day);
!  WS2:       Organic matter sinking velocity, (m/day);
!  WS3:       Phytoplankton settling velocity, (m/day);
!  FD2:       Fraction of dissolved CBOD;
!  FD6:       Fraction of dissolved organic nitrogen;
!  FD8:       Fraction of dissolved organic phosphorus;
!  FON:       Fraction of dead and respired phytoplankton recycled to
!                the organic nitorgen pool;
!  FOP:       Fraction of dead and respired phytoplankton recycled to
!                the organic phosphorus pool;

!  Ratio_NC:  Ratio of nitrogen to carbon in phytoplankton, 
!                16/106 by Redfield ratio, (mg N/mg C);
!  Ratio_PC:  Ratio of phosphorus to carbon in phytoplankton, 
!                1/106 by Redfield ratio, (mg P/mg C);
!  FBON:   Fraction of dead and respired phytoplankton recycled to
!                the organic nitorgen pool;
!  FBOP:   Fraction of dead and respired phytoplankton recycled to
!                the organic phosphorus pool;
!  RatioB_NC: Ratio of nitrogen to carbon, (mg N/mg C);
!  RatioB_PC: Ratio of phosphorus to carbon, (mg P/mg C);

!  Time_U:    Time (in hour) of sunrise;
!  Time_D:    Time (in hour) of sunset;
!  Solar_S:   Optimum solar radiation rate, (langleys/day);
!  Solar_A:   Total daily solar radiation, (langleys/day);

!
!    The definition for each parameter in the sediment layer is:
!
!  KB_ds:     Organic Carbon (as CBOD) decomposition rate at 
!                20 degree, (day^-1);
!  KB_pzd:    Anaerobic algal decomposition rate at 20 degree, (day^-1);
!  KB_deni:   Denitrification rate at 20 degree, (day^-1);
!  KB_ond:    Organic nitrogen decomposition rate at 20 degree, (day^-1);
!  KB_opd:    Organic phosphorus decomposition rate at 20 degree, (day^-1);

!  TempB_ds:  Temperature coefficient of organic carbon decomposition; 
!  TempB_pzd: Temperature coefficient of anaerobic algal decomposition; 
!  TempB_deni:Temperature coefficient of denitrification; 
!  TempB_ond: Temperature coefficient of organic nitrogen decomposition; 
!  TempB_opd: Temperature coefficient of organic phosphorus decomposition; 

!  FDB2:      Fraction of dissolved CBOD in sediment;
!  FDB4:      Fraction of dissolved NH3 in sediment;
!  FDB5:      Fraction of dissolved NO3 in sediment;
!  FDB6:      Fraction of dissolved ON in sediment;
!  FDB7:      Fraction of dissolved OPO4 in sediment;
!  FDB8:      Fraction of dissolved OP in sediment;

!  Diff_z:    Diffusive exchange coefficient, (m^2/day);
!  Dep_ben:   Benthic layer depth, (m);
!---------------------------------------------------------------------------
   USE CONTROL
   IMPLICIT NONE
   CHARACTER(LEN=200)  :: HEADLINE
   CHARACTER(LEN=80)  :: ISTR

   ISTR = "./"//TRIM(INPDIR)//"/"

   OPEN(31,FILE=TRIM(ISTR)//'wqm_para.dat',STATUS='old')
!   OPEN(32,FILE=TRIM(ISTR)//'wqm_para2.dat',STATUS='old')

! skip head line
   READ(31,*) HEADLINE    
   READ(31,*) K_deox          
   READ(31,*) K_nitr            
   READ(31,*) K_resp 
   READ(31,*) K_resp1 
   READ(31,*) K_deni        
   READ(31,*) K_grow           
   READ(31,*) K_mort          
   READ(31,*) K_mine1      
   READ(31,*) K_mine2  

! skip head line
   READ(31,*) HEADLINE       
   READ(31,*) KBOD
   READ(31,*) KNITR 
   READ(31,*) KNO3 
   READ(31,*) KmN 
   READ(31,*) KmP 
   READ(31,*) KmPC 

! skip head line
   READ(31,*) HEADLINE    
   READ(31,*) Temp_reae
   READ(31,*) Temp_deox 
   READ(31,*) Temp_nitr 
   READ(31,*) Temp_resp 
   READ(31,*) Temp_deni 
   READ(31,*) Temp_grow 
   READ(31,*) Temp_mort 
   READ(31,*) Temp_mine1 
   READ(31,*) Temp_mine2 
   READ(31,*) Temp_sod 

! skip head line
   READ(31,*) HEADLINE    
   READ(31,*) SOD
   READ(31,*) WSS2 
   READ(31,*) WSS3 
   READ(31,*) FD2 
   READ(31,*) FD6 
   READ(31,*) FD8 
   READ(31,*) FON 
   READ(31,*) FOP
   
   ! skip head line
   READ(31,*) HEADLINE    
   READ(31,*) Ratio_NC 
   READ(31,*) Ratio_PC 
   READ(31,*) FBON
   READ(31,*) FBOP
   READ(31,*) RatioB_NC
   READ(31,*) RatioB_PC

    ! skip head line
   READ(31,*) HEADLINE    
   READ(31,*) Time_U 
   READ(31,*) Time_D 
   READ(31,*) Solar_S 
   READ(31,*) Solar_A 

   ! skip head line
   READ(31,*) HEADLINE    
   READ(31,*) Rsed_NH4
   READ(31,*) Rsed_NO3
   READ(31,*) Rsed_OP4
   READ(31,*) Diff_z
   READ(31,*) Dep_ben

  ! skip head line
   READ(31,*) HEADLINE         
   READ(31,*) KB_ds
   READ(31,*) KB_pzd
   READ(31,*) KB_deni
   READ(31,*) KB_ond
   READ(31,*) KB_opd

  ! skip head line
   READ(31,*) HEADLINE         
   READ(31,*) TempB_ds
   READ(31,*) TempB_pzd
   READ(31,*) TempB_deni
   READ(31,*) TempB_ond
   READ(31,*) TempB_opd

   ! skip head line
   READ(31,*) HEADLINE         
   READ(31,*) FDB2
   READ(31,*) FDB4
   READ(31,*) FDB5
   READ(31,*) FDB6
   READ(31,*) FDB7
   READ(31,*) FDB8
     
!   CLOSE(32)
   CLOSE(31)
   RETURN
   END SUBROUTINE WQMPARA
!=============================================================================!

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
                                                                                                                           
   SUBROUTINE ALLOC_WQM_VARS
!=============================================================================!
!  Allocate Data for Water Quality Model Variables                            !
!=============================================================================!
                                                                                                                           
   USE MOD_PREC
   USE LIMS
   USE CONTROL 
   IMPLICIT NONE
   INTEGER :: MEMCNT,IERR,I
   REAL(SP) :: MEMTOT
                                                                                                                           
!=============================================================================!
   ALLOCATE(CS(MT,KB))           ;CS        = ZERO
   ALLOCATE(K_REAE(MT,KB))       ;K_REAE    = ZERO
   ALLOCATE(PNH3G(MT,KB))        ;PNH3G     = ZERO
   ALLOCATE(RNUTR(MT,KB))        ;RNUTR     = ZERO
   ALLOCATE(RLIGHT(MT,KB))       ;RLIGHT    = ZERO
   ALLOCATE(GPP(MT,KB))          ;GPP       = ZERO
   ALLOCATE(DPP(MT,KB))          ;DPP       = ZERO
   ALLOCATE(SODD(MT,KB))         ;SODD      = ZERO
   ALLOCATE(K_RESPP(MT))         ;K_RESPP   = ZERO
   ALLOCATE(F_ONN(MT))           ;F_ONN     = ZERO
   ALLOCATE(F_OPP(MT))           ;F_OPP     = ZERO
   ALLOCATE(K_NITRR(MT,KB))      ;K_NITRR   = ZERO
   ALLOCATE(RSED1(MT))           ;RSED1     = ZERO
   ALLOCATE(RSED2(MT))           ;RSED2     = ZERO
   ALLOCATE(RSED3(MT))           ;RSED3     = ZERO
   ALLOCATE(WQM(0:MT,KB,NB))     ;WQM       = ZERO
   ALLOCATE(WQM_T(0:MT,KB,NB))   ;WQM_T     = ZERO
   ALLOCATE(WQM_F(0:MT,KB,NB))   ;WQM_F     = ZERO
   ALLOCATE(SEDWQM(0:MT,NB))     ;SEDWQM    = ZERO
   ALLOCATE(WMEAN(0:MT,KB,NB))   ;WMEAN     = ZERO
   ALLOCATE(WWSURF(MT,NB))       ;WWSURF    = ZERO
   ALLOCATE(WDIS(NUMQBC,NB))     ;WDIS      = ZERO
      MEMCNT = MT*KB*NB*4+MT*KB*9+MT*6+MT*NB*2+NUMQBC*NB 

!---------------report approximate memory usage-------------------------------------!
                                                                                                                           
   MEMTOT = MEMCNT*4
# if defined (MULTIPROCESSOR)
   IF(PAR)CALL MPI_REDUCE(MEMCNT,MEMTOT,1,MPI_F,MPI_SUM,0,MPI_COMM_WORLD,IERR)
# endif
   IF(MSR)WRITE(IPT,*)'!  # WQM MBYTES REQUIRED :',MEMTOT/1E+6
   IF(MSR .AND. .NOT.SERIAL )WRITE(IPT,*)'!  # AVERAGE MBYTES/PROC :',MEMTOT/(1E+6*NPROCS)
                                                                                                                           

   RETURN
   END SUBROUTINE ALLOC_WQM_VARS
!=============================================================================!

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

!=============================================================================!
   SUBROUTINE INITIAL_WQM
!=============================================================================!
!    Initialize Water Quality Variables (WQM(I,K,Nl),N1=1,NB)                 !
!    and Mean Values (WMEAN(I,K,N1),N1=1,NB)                                  !
!=============================================================================!

   USE CONTROL
   USE LIMS
#  if defined (MULTIPROCESSOR)
   USE MOD_PAR
#  endif      
   IMPLICIT NONE
   
   REAL(SP) :: WQM1,WQM2,WQM3,WQM4,WQM5,WQM6,WQM7,WQM8
   CHARACTER(LEN=80) :: ISTR
   CHARACTER(LEN=80) :: HEADLINE
   INTEGER:: I

   IF(.NOT. WQM_ON)RETURN
!-----------------------------------------------------------------------------!
!   READ IN INITIAL WATER QUALITY VARIABLES FROM: 'casename_initial_wqm.dat'  !
!-----------------------------------------------------------------------------!
   ISTR = "./"//TRIM(INPDIR)//"/"//trim(casename)
   OPEN(1,FILE=TRIM(ISTR)//'_initial_wqm.dat',STATUS='old')
   
   ! skip head lines
   DO I=1,8
   READ(1,*) HEADLINE     
   END DO
      
   READ(1,*) WQM1 
   READ(1,*) WQM2
   READ(1,*) WQM3
   READ(1,*) WQM4
   READ(1,*) WQM5
   READ(1,*) WQM6
   READ(1,*) WQM7
   READ(1,*) WQM8

   WQM(1:M,1:KBM1,1) = WQM1
   WQM(1:M,1:KBM1,2) = WQM2
   WQM(1:M,1:KBM1,3) = WQM3
   WQM(1:M,1:KBM1,4) = WQM4
   WQM(1:M,1:KBM1,5) = WQM5
   WQM(1:M,1:KBM1,6) = WQM6
   WQM(1:M,1:KBM1,7) = WQM7
   WQM(1:M,1:KBM1,8) = WQM8

   WQM_T(1:M,1:KBM1,1) = WQM1
   WQM_T(1:M,1:KBM1,2) = WQM2
   WQM_T(1:M,1:KBM1,3) = WQM3
   WQM_T(1:M,1:KBM1,4) = WQM4
   WQM_T(1:M,1:KBM1,5) = WQM5
   WQM_T(1:M,1:KBM1,6) = WQM6
   WQM_T(1:M,1:KBM1,7) = WQM7
   WQM_T(1:M,1:KBM1,8) = WQM8

   WMEAN(1:M,1:KBM1,1) = WQM1
   WMEAN(1:M,1:KBM1,2) = WQM2
   WMEAN(1:M,1:KBM1,3) = WQM3
   WMEAN(1:M,1:KBM1,4) = WQM4
   WMEAN(1:M,1:KBM1,5) = WQM5
   WMEAN(1:M,1:KBM1,6) = WQM6
   WMEAN(1:M,1:KBM1,7) = WQM7
   WMEAN(1:M,1:KBM1,8) = WQM8

   CLOSE(1)
       
   RETURN
   END SUBROUTINE INITIAL_WQM


!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

!==============================================================================!
   SUBROUTINE BCS_FORCE_WQM           
!==============================================================================|
!   Set Up the Following Boundary Conditions:                                  |
!     Freshwater River Discharge for Water Quality 		               |
!==============================================================================|

!------------------------------------------------------------------------------|

   USE MOD_CLOCK
   USE LIMS
   USE MOD_UTILS
   USE CONTROL
   USE BCS
# if defined (MULTIPROCESSOR)
   USE MOD_PAR
# endif
   IMPLICIT NONE
   REAL(SP) :: COMT(80)
   REAL(SP) :: TTIME
   REAL(SP) :: FTEMP1,FTEMP2,FTEMP3,FTEMP4,FTEMP5,FTEMP6,FTEMP7,FTEMP8
   REAL(SP) :: RBUF1,RBUF2,RBUF3,RBUF4,RBUF5,RBUF6,RBUF7,RBUF8
   REAL(SP), ALLOCATABLE :: RTEMP1(:,:)
   REAL(SP), ALLOCATABLE :: RTEMP2(:,:)
   REAL(SP), ALLOCATABLE :: RTEMP3(:,:)
   REAL(SP), ALLOCATABLE :: RTEMP4(:,:)
   REAL(SP), ALLOCATABLE :: RTEMP5(:,:)
   REAL(SP), ALLOCATABLE :: RTEMP6(:,:)
   REAL(SP), ALLOCATABLE :: RTEMP7(:,:)
   REAL(SP), ALLOCATABLE :: RTEMP8(:,:)
   INTEGER,  ALLOCATABLE :: TEMP(:)
   INTEGER   I,J,K,NQTIME,IERR
   CHARACTER(LEN=13) :: TSTRING
   LOGICAL FEXIST
   CHARACTER(LEN=120) :: FNAME
    
!------------------------------------------------------------------------------|


!----------------------------REPORT--------------------------------------------!
   IF(MSR)WRITE(IPT,*  )'!'
   IF(MSR)WRITE(IPT,*)'!           SETTING UP PRESCRIBED B.C. OF WATER QUALITY'
   IF(MSR)WRITE(IPT,*  )'!'

!==============================================================================|
!   Input River/Dam/Intake/Outfall Boundary Values of Water Quality            |
!==============================================================================|
 
   IF(NUMQBC_GL > 0) THEN
!------------------------------------------------------------------------------!
!  Read Number of Current Observations and Coordinates of Each                 !
!------------------------------------------------------------------------------!
                                                                                                                           
     FNAME = "./"//TRIM(INPDIR)//"/"//trim(casename)//"_riv_wqm.dat"
!
!----Make Sure Water Quality River Input Data File Exists----------------------!
!
     INQUIRE(FILE=TRIM(FNAME),EXIST=FEXIST)
     IF(MSR .AND. .NOT.FEXIST)THEN
       WRITE(IPT,*)'WATER QUALITY RIVER DATA: ',FNAME,' DOES NOT EXIST'
       WRITE(IPT,*)'HALTING.....'
       CALL PSTOP
     END IF
                                                                                                                           
!     OPEN(UNIT=INRIVW,FILE=FNAME,FORM='FORMATTED')
     OPEN(UNIT=INRIVW,FILE=FNAME)    
     IF(MSR)READ(INRIVW,*) NQTIME  

#    if defined (MULTIPROCESSOR)
     IF(PAR)CALL MPI_BCAST(NQTIME,1,MPI_INTEGER,0,MPI_COMM_WORLD,IERR)
#    endif

     QBC_TM%NTIMES = NQTIME
     QBC_TM%LABEL  = "Freshwater Discharge of Water Quality" 
     ALLOCATE(QBC_TM%TIMES(NQTIME))
     ALLOCATE(RTEMP1(NUMQBC_GL,NQTIME))
     ALLOCATE(RTEMP2(NUMQBC_GL,NQTIME))
     ALLOCATE(RTEMP3(NUMQBC_GL,NQTIME))
     ALLOCATE(RTEMP4(NUMQBC_GL,NQTIME))
     ALLOCATE(RTEMP5(NUMQBC_GL,NQTIME))
     ALLOCATE(RTEMP6(NUMQBC_GL,NQTIME))
     ALLOCATE(RTEMP7(NUMQBC_GL,NQTIME))
     ALLOCATE(RTEMP8(NUMQBC_GL,NQTIME))

     IF(MSR)THEN
       DO I = 1, NQTIME
         READ(INRIVW,*) TTIME
         QBC_TM%TIMES(I) = TTIME
         READ(INRIVW,*) (RTEMP1(J,I),J = 1,NUMQBC_GL)
         READ(INRIVW,*) (RTEMP2(J,I),J = 1,NUMQBC_GL)
         READ(INRIVW,*) (RTEMP3(J,I),J = 1,NUMQBC_GL)
         READ(INRIVW,*) (RTEMP4(J,I),J = 1,NUMQBC_GL)
         READ(INRIVW,*) (RTEMP5(J,I),J = 1,NUMQBC_GL)
         READ(INRIVW,*) (RTEMP6(J,I),J = 1,NUMQBC_GL)
         READ(INRIVW,*) (RTEMP7(J,I),J = 1,NUMQBC_GL)
         READ(INRIVW,*) (RTEMP8(J,I),J = 1,NUMQBC_GL)
         WRITE(IOPRT,5000) TTIME
         WRITE(IOPRT,5000) (RTEMP1(J,I),J = 1,NUMQBC_GL)
         WRITE(IOPRT,5000) (RTEMP2(J,I),J = 1,NUMQBC_GL)
         WRITE(IOPRT,5000) (RTEMP3(J,I),J = 1,NUMQBC_GL)
         WRITE(IOPRT,5000) (RTEMP4(J,I),J = 1,NUMQBC_GL)
         WRITE(IOPRT,5000) (RTEMP5(J,I),J = 1,NUMQBC_GL)
         WRITE(IOPRT,5000) (RTEMP6(J,I),J = 1,NUMQBC_GL)
         WRITE(IOPRT,5000) (RTEMP7(J,I),J = 1,NUMQBC_GL)
         WRITE(IOPRT,5000) (RTEMP8(J,I),J = 1,NUMQBC_GL)
       END DO
     END IF

#    if defined (MULTIPROCESSOR)
     IF(PAR)CALL MPI_BCAST(QBC_TM%TIMES,NQTIME,MPI_F,0,MPI_COMM_WORLD,IERR)
     IF(PAR)CALL MPI_BCAST(RTEMP1,NUMQBC_GL*NQTIME,MPI_F,0,MPI_COMM_WORLD,IERR)
     IF(PAR)CALL MPI_BCAST(RTEMP2,NUMQBC_GL*NQTIME,MPI_F,0,MPI_COMM_WORLD,IERR)
     IF(PAR)CALL MPI_BCAST(RTEMP3,NUMQBC_GL*NQTIME,MPI_F,0,MPI_COMM_WORLD,IERR)
     IF(PAR)CALL MPI_BCAST(RTEMP4,NUMQBC_GL*NQTIME,MPI_F,0,MPI_COMM_WORLD,IERR)
     IF(PAR)CALL MPI_BCAST(RTEMP5,NUMQBC_GL*NQTIME,MPI_F,0,MPI_COMM_WORLD,IERR)
     IF(PAR)CALL MPI_BCAST(RTEMP6,NUMQBC_GL*NQTIME,MPI_F,0,MPI_COMM_WORLD,IERR)
     IF(PAR)CALL MPI_BCAST(RTEMP7,NUMQBC_GL*NQTIME,MPI_F,0,MPI_COMM_WORLD,IERR)
     IF(PAR)CALL MPI_BCAST(RTEMP8,NUMQBC_GL*NQTIME,MPI_F,0,MPI_COMM_WORLD,IERR)
#    endif

!
!----TRANSFORM TO LOCAL ARRAYS-------------------------------------------------|
!
     IF(NUMQBC > 0)THEN
       ALLOCATE(DWDIS(NUMQBC,NB,NQTIME))

       IF(SERIAL)THEN
         DWDIS(1:NUMQBC_GL,1,:) = RTEMP1(1:NUMQBC_GL,:)
         DWDIS(1:NUMQBC_GL,2,:) = RTEMP2(1:NUMQBC_GL,:)
         DWDIS(1:NUMQBC_GL,3,:) = RTEMP3(1:NUMQBC_GL,:)
         DWDIS(1:NUMQBC_GL,4,:) = RTEMP4(1:NUMQBC_GL,:)
         DWDIS(1:NUMQBC_GL,5,:) = RTEMP5(1:NUMQBC_GL,:)
         DWDIS(1:NUMQBC_GL,6,:) = RTEMP6(1:NUMQBC_GL,:)
         DWDIS(1:NUMQBC_GL,7,:) = RTEMP7(1:NUMQBC_GL,:)
         DWDIS(1:NUMQBC_GL,8,:) = RTEMP8(1:NUMQBC_GL,:)
       END IF

#     if defined (MULTIPROCESSOR)
       IF(PAR)THEN
       DO I=1,NQTIME
         DWDIS(1:NUMQBC,1,I) = RTEMP1(RIV_GL2LOC(1:NUMQBC),I) 
         DWDIS(1:NUMQBC,2,I) = RTEMP2(RIV_GL2LOC(1:NUMQBC),I) 
         DWDIS(1:NUMQBC,3,I) = RTEMP3(RIV_GL2LOC(1:NUMQBC),I) 
         DWDIS(1:NUMQBC,4,I) = RTEMP4(RIV_GL2LOC(1:NUMQBC),I) 
         DWDIS(1:NUMQBC,5,I) = RTEMP5(RIV_GL2LOC(1:NUMQBC),I) 
         DWDIS(1:NUMQBC,6,I) = RTEMP6(RIV_GL2LOC(1:NUMQBC),I) 
         DWDIS(1:NUMQBC,7,I) = RTEMP7(RIV_GL2LOC(1:NUMQBC),I) 
         DWDIS(1:NUMQBC,8,I) = RTEMP8(RIV_GL2LOC(1:NUMQBC),I) 
       END DO
       END IF
#     endif

     END IF

     DEALLOCATE(RTEMP1,RTEMP2,RTEMP3,RTEMP4,RTEMP5,RTEMP6,RTEMP7,RTEMP8)
     
   CLOSE(INRIVW)
!
!--REPORT RESULTS--------------------------------------------------------------!
!
   ALLOCATE(TEMP(NPROCS))
   TEMP(1)  = NUMQBC 
   FTEMP1 = 0.0_SP; FTEMP2 = 0.0_SP; FTEMP3 = 0.0_SP; FTEMP4 = 0.0_SP;
   FTEMP5 = 0.0_SP; FTEMP6 = 0.0_SP; FTEMP7 = 0.0_SP; FTEMP8 = 0.0_SP;
   IF(NUMQBC > 0) THEN
     FTEMP1 = MAXVAL(DWDIS(:,1,:))
     FTEMP2 = MAXVAL(DWDIS(:,2,:))
     FTEMP3 = MAXVAL(DWDIS(:,3,:))
     FTEMP4 = MAXVAL(DWDIS(:,4,:))
     FTEMP5 = MAXVAL(DWDIS(:,5,:))
     FTEMP6 = MAXVAL(DWDIS(:,6,:))
     FTEMP7 = MAXVAL(DWDIS(:,7,:))
     FTEMP8 = MAXVAL(DWDIS(:,8,:))
   END IF
   RBUF1 = FTEMP1; RBUF2 = FTEMP2; RBUF3 = FTEMP3; RBUF4 = FTEMP4; 
   RBUF5 = FTEMP5; RBUF6 = FTEMP6; RBUF7 = FTEMP7; RBUF8 = FTEMP8; 

# if defined (MULTIPROCESSOR) 
   IF(PAR)CALL MPI_GATHER(NUMQBC,1,MPI_INTEGER,TEMP,1,MPI_INTEGER,0,MPI_COMM_WORLD,IERR)
   IF(PAR)CALL MPI_REDUCE(FTEMP1,RBUF1,1,MPI_F,MPI_MAX,0,MPI_COMM_WORLD,IERR)
   IF(PAR)CALL MPI_REDUCE(FTEMP2,RBUF2,1,MPI_F,MPI_MAX,0,MPI_COMM_WORLD,IERR)
   IF(PAR)CALL MPI_REDUCE(FTEMP3,RBUF3,1,MPI_F,MPI_MAX,0,MPI_COMM_WORLD,IERR)
   IF(PAR)CALL MPI_REDUCE(FTEMP4,RBUF4,1,MPI_F,MPI_MAX,0,MPI_COMM_WORLD,IERR)
   IF(PAR)CALL MPI_REDUCE(FTEMP5,RBUF5,1,MPI_F,MPI_MAX,0,MPI_COMM_WORLD,IERR)
   IF(PAR)CALL MPI_REDUCE(FTEMP6,RBUF6,1,MPI_F,MPI_MAX,0,MPI_COMM_WORLD,IERR)
   IF(PAR)CALL MPI_REDUCE(FTEMP7,RBUF7,1,MPI_F,MPI_MAX,0,MPI_COMM_WORLD,IERR)
   IF(PAR)CALL MPI_REDUCE(FTEMP8,RBUF8,1,MPI_F,MPI_MAX,0,MPI_COMM_WORLD,IERR)
# endif

   END IF !! NUMQBC_GL > 0

   IF(MSR)WRITE(*,*)'!'
   IF(NUMQBC_GL == 0)THEN
     IF(MSR)WRITE(*,*)'!  FRESHWATER FLUX       :    NONE'
   ELSE
     IF(MSR)WRITE(*,100)'!  FRESHWATER POINTS     :',NUMQBC_GL, (TEMP(I),I=1,NPROCS)
     IF(MSR)CALL GETTIME(TSTRING,3600*INT(QBC_TM%TIMES(1)))
     IF(MSR)WRITE(*,102)'!  FWATER DATA BEGIN     :  ',TSTRING           
     IF(MSR)CALL GETTIME(TSTRING,3600*INT(QBC_TM%TIMES(QBC_TM%NTIMES)))
     IF(MSR)WRITE(*,102)'!  FWATER DATA END       :  ',TSTRING
     IF(MSR)WRITE(*,101)'!  MAX DWDIS1             :',RBUF1
     IF(MSR)WRITE(*,101)'!  MAX DWDIS2             :',RBUF2
     IF(MSR)WRITE(*,101)'!  MAX DWDIS3             :',RBUF3
     IF(MSR)WRITE(*,101)'!  MAX DWDIS4             :',RBUF4
     IF(MSR)WRITE(*,101)'!  MAX DWDIS5             :',RBUF5
     IF(MSR)WRITE(*,101)'!  MAX DWDIS6             :',RBUF6
     IF(MSR)WRITE(*,101)'!  MAX DWDIS7             :',RBUF7
     IF(MSR)WRITE(*,101)'!  MAX DWDIS8             :',RBUF8
     DEALLOCATE(TEMP)
   END IF
  
!
!--Format Statements-----------------------------------------------------------!
!

   100  FORMAT(1X,A26,I6," =>",2X,4(I5,1H,))
   101  FORMAT(1X,A26,F10.4)  
   102  FORMAT(1X,A28,A13)  
   1000 FORMAT(80A1)
   5000 FORMAT(8E14.5)

   RETURN
   END SUBROUTINE BCS_FORCE_WQM
!==============================================================================|

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

!=============================================================================!
   SUBROUTINE ADV_WQM  
!=============================================================================!
!                                                                             !
!   This subroutine is used to calculate the eight variables of water         !
!   quality model in the Satilla River. They are:                             !
!     (1) Dissolved Oxygen (DO)                                               !
!     (2) Carbonaceous Biochemical Oxygen Demand (CBOD)                       !
!     (3) Phytoplankton (PHYT)                                                !
!     (4) Ammonia Nitrogen (NH4)                                              !
!     (5) Nitrate and Nitrite Nitrogen (NO3+NO2)                              !
!     (6) Organic Nitrogen (ON)                                               !
!     (7) Orthophosphorus or Inorganic Phosphorus (OPO4)                      !
!     (8) Organic Phosphorus (OP)                                             !
!   This subroutine only includes advection, sources and sinks, and           !
!   horizontal diffusion terms.                                               !
!                                                                             !
!   (Version(01/05/2004)						      !
!=============================================================================!

   USE ALL_VARS
   USE BCS
# if defined (MULTIPROCESSOR)
   USE MOD_PAR   
# endif
#  if defined (WET_DRY)
   USE MOD_WD
#  endif
#  if defined (SPHERICAL)
   USE MOD_SPHERICAL
#  endif
   IMPLICIT NONE
   REAL(SP), DIMENSION(0:MT,KB,NB)  :: XFLUX,RF
   REAL(SP), DIMENSION(M)           :: PUPX,PUPY,PVPX,PVPY
   REAL(SP), DIMENSION(M)           :: PFPX,PFPY,PFPXD,PFPYD,VISCOFF
   REAL(SP), DIMENSION(3*(NT),KBM1) :: DTIJ
   REAL(SP), DIMENSION(3*(NT),KBM1) :: UVN
   REAL(SP) :: FFD,FF1,X11,Y11,X22,Y22,X33,Y33,TMP1,TMP2,XI,YI
   REAL(SP) :: DXA,DYA,DXB,DYB,FIJ1,FIJ2,UN
   REAL(SP) :: TXX,TYY,FXX,FYY,VISCOF,EXFLUX,TEMP
   REAL(SP) :: FACT,FM1
   REAL(SP) :: TT,TTIME,STPOINT
   INTEGER  :: I,I1,I2,IA,IB,J,J1,J2,JTMP,K,JJ,N1,II
   REAL(SP) :: WQM1MIN, WQM1MAX, WQM2MIN, WQM2MAX
# if defined (SPHERICAL)
   REAL(DP) :: ty,txpi,typi
   REAL(DP) :: XTMP,XTMP1
   REAL(DP) :: X1_DP,Y1_DP,X2_DP,Y2_DP,XII,YII
   REAL(DP) :: X11_TMP,Y11_TMP,X33_TMP,Y33_TMP
# endif
#  if defined (MPDATA)
   REAL(SP) :: WQMMIN,WQMMAX,XXXX
   REAL(SP), DIMENSION(0:MT,KB)     :: WQM_S    
   REAL(SP), DIMENSION(0:MT,KB)     :: WQM_SF   
   REAL(SP), DIMENSION(0:MT,KB)     :: WWWS     
   REAL(SP), DIMENSION(0:MT,KB)     :: WWWSF   
   REAL(SP), DIMENSION(0:MT)        :: DTWWWS  
   REAL(SP), DIMENSION(0:MT,KB)     :: ZZZFLUX !! temporary total flux in corrected part
   REAL(SP), DIMENSION(0:MT,KB)     :: BETA    !! temporary beta coefficient in corrected part
   REAL(SP), DIMENSION(0:MT,KB)     :: BETAIN  !! temporary beta coefficient in corrected part
   REAL(SP), DIMENSION(0:MT,KB)     :: BETAOUT !! temporary beta coefficient in corrected part
   REAL(SP), DIMENSION(0:MT,KB)     :: WQM_FRESH    

   INTEGER ITERA, NTERA
#  endif
!------------------------------------------------------------------------------

   FACT = 0.0_SP
   FM1  = 1.0_SP
   IF(HORZMIX == 'closure')THEN
     FACT = 1.0_SP
     FM1  = 0.0_SP
   END IF

!
!--Initialize Fluxes-----------------------------------------------------------
!
   XFLUX = 0.0_SP

!
!--Loop Over Control Volume Sub-Edges And Calculate Normal Velocity------------
!
   DO I=1,NCV
     I1=NTRG(I)
     DO K=1,KBM1
       DTIJ(I,K)=DT1(I1)*DZ1(I1,K)
       UVN(I,K)=V(I1,K)*DLTXE(I) - U(I1,K)*DLTYE(I)
     END DO
   END DO

   TTIME=THOUR

   RF = 0.0_SP
!
!------- CALCULATE SOURCE AND SINK TERMS FOR EVERY VARIABLE -----------
!
   DO I = 1,M
     IF(D(I) > 0.0_SP) Then
       DO K = 1, KBM1
         TT = 0.0_SP
!          TT = T1(I,K)-20.0_SP !!JQI comment for test  !! JQI, In Zhengs code, TT=0
         
!-------------------- For dissolved oxygen ----------------------------
         IF(H(I) <= 0.5_SP) THEN
          RF(I,K,1) =                                                         &
          K_REAE(I,K)*TEMP_REAE**TT*(CS(I,K)-WQM(I,K,1))-                     &
          K_DEOX*TEMP_DEOX**TT*WQM(I,K,1)*WQM(I,K,2)/(KBOD+WQM(I,K,1))-       &
          K_NITRR(I,K)*TEMP_NITR**TT*WQM(I,K,1)*WQM(I,K,4)/                   &
          (KNITR+WQM(I,K,1))*2.0_SP*32.0_SP/14.0_SP-                          &
          DPP(I,K)*WQM(I,K,3)*32.0_SP/12.0_SP-                                &
          SODD(I,K)/0.7_SP*TEMP_SOD**TT+                                      &
          GPP(I,K)*(32.0_SP/12.0_SP+48.0_SP*RATIO_NC*(1-PNH3G(I,K))/14.0_SP)* &
          WQM(I,K,3) - K_RESP1 * 32 * 24 * 0.001_SP * 2                
         ELSE
          RF(I,K,1) =                                                         &
          K_REAE(I,K)*TEMP_REAE**TT*(CS(I,K)-WQM(I,K,1))-                     &
          K_DEOX*TEMP_DEOX**TT*WQM(I,K,1)*WQM(I,K,2)/(KBOD+WQM(I,K,1))-       &
          K_NITRR(I,K)*TEMP_NITR**TT*WQM(I,K,1)*WQM(I,K,4)/                   &
          (KNITR+WQM(I,K,1))*2.0_SP*32.0_SP/14.0_SP-                          &
          DPP(I,K)*WQM(I,K,3)*32.0_SP/12.0_SP-                                &
          SODD(I,K)/0.7_SP*TEMP_SOD**TT+                                      &
          GPP(I,K)*(32.0_SP/12.0_SP+48.0_SP*RATIO_NC*(1-PNH3G(I,K))/14.0_SP)* &
          WQM(I,K,3) - K_RESP1 * 32 * 24 * 0.001_SP
         END IF

         RF(I,K,1) = RF(I,K,1) / DAY_SEC
     
!------------- For carbonaceous biochemical oxygen demand -------------
         RF(I,K,2) =                                                           &
         32.0_SP/12.0_SP*DPP(I,K)*WQM(I,K,3)-                                  &
         K_DEOX*TEMP_DEOX**TT*WQM(I,K,1)*WQM(I,K,2)/(KBOD+WQM(I,K,1))-         &
         K_DENI*TEMP_DENI**TT*WQM(I,K,5)*KNO3/(KNO3+WQM(I,K,1))*5.0_SP/4.0_SP* &
         12.0_SP/14.0_SP*32.0_SP/12.0_SP-                                      &
         WSS2*(1-FD2)*WQM(I,K,2)/MAX(D(I),1.5_SP)  
                          
         RF(I,K,2) = RF(I,K,2) / DAY_SEC
     
!-------------------------- For phytoplankton -------------------------
         RF(I,K,3) =                                                           &
         GPP(I,K)*WQM(I,K,3)-DPP(I,K)*WQM(I,K,3)-WSS3*WQM(I,K,3)/MAX(D(I),1.5_SP)

         RF(I,K,3) = RF(I,K,3) / DAY_SEC
     
!----------------------------- For ammonia ----------------------------
         RF(I,K,4) =                                                           &
         DPP(I,K)*RATIO_NC*(1-F_ONN(I))*WQM(I,K,3)+                            &
         K_MINE1*TEMP_MINE1**TT*WQM(I,K,3)*WQM(I,K,6)/                         & 
         (KMPC+WQM(I,K,3))-                                                    &
         GPP(I,K)*RATIO_NC*PNH3G(I,K)*WQM(I,K,3)-                              &
         K_NITRR(I,K)*TEMP_NITR**TT*WQM(I,K,1)*WQM(I,K,4)/                     &
         (KNITR+WQM(I,K,1))

         RF(I,K,4) = RF(I,K,4) / DAY_SEC
     
!----------------------- For nitrate and nitrite ----------------------
         RF(I,K,5) =                                                           &
         K_NITRR(I,K)*TEMP_NITR**TT*WQM(I,K,1)*WQM(I,K,4)/                     &
         (KNITR+WQM(I,K,1))-GPP(I,K)*RATIO_NC*(1-PNH3G(I,K))*                  &
         WQM(I,K,3)-K_DENI*TEMP_DENI**TT*WQM(I,K,5)*KNO3/                      &
         (KNO3+WQM(I,K,1))

         RF(I,K,5) = RF(I,K,5) / DAY_SEC
     
!------------------------ For organic nitrogen ------------------------
         RF(I,K,6) =                                                           &
         DPP(I,K)*RATIO_NC*F_ONN(I)*WQM(I,K,3)-                                &
         K_MINE1*TEMP_MINE1**TT*WQM(I,K,3)*WQM(I,K,6)/                         &
         (KMPC+WQM(I,K,3))-                                                    &
         WSS3*WQM(I,K,6)*(1-FD6)/MAX(D(I),1.5_SP)                            

         RF(I,K,6) = RF(I,K,6) / DAY_SEC
     
!--------------------- For inorganic phosphorus -----------------------
         RF(I,K,7) =                                                           &
         DPP(I,K)*RATIO_PC*(1-FOP)*WQM(I,K,3)+                                 &
         K_MINE2*TEMP_MINE2**TT*WQM(I,K,3)*WQM(I,K,8)/                         &
         (KMPC+WQM(I,K,3))-                                                    &
         GPP(I,K)*RATIO_PC*WQM(I,K,3)                                            

         RF(I,K,7) = RF(I,K,7) / DAY_SEC
     
!---------------------- For organic phosphorus ------------------------
         RF(I,K,8) =                                                           &
         DPP(I,K)*RATIO_PC*F_OPP(I)*WQM(I,K,3)-                                &
         K_MINE2*TEMP_MINE2**TT*WQM(I,K,3)*WQM(I,K,8)/                         &
         (KMPC+WQM(I,K,3))-                                                    &
         WSS3*WQM(I,K,8)*(1-FD8)/MAX(D(I),1.5_SP)

         RF(I,K,8) = RF(I,K,8) / DAY_SEC

       END DO
     END IF
   END DO

!
!--Calculate the Advection and Horizontal Diffusion Terms----------------------
!

   DO N1=1,NB
     DO K=1,KBM1
       PFPX  = 0.0_SP
       PFPY  = 0.0_SP
       PFPXD = 0.0_SP
       PFPYD = 0.0_SP

       DO I=1,M
         DO J=1,NTSN(I)-1
           I1=NBSN(I,J)
           I2=NBSN(I,J+1)

#    if defined (WET_DRY)
         IF(ISWETN(I1) == 0 .AND. ISWETN(I2) == 1)THEN
          FFD=0.5_SP*(WQM(I,K,N1)+WQM(I2,K,N1)           &
	      -WMEAN(I,K,N1)-WMEAN(I2,K,N1))
          FF1=0.5_SP*(WQM(I,K,N1)+WQM(I2,K,N1))
	 ELSE IF(ISWETN(I1) == 1 .AND. ISWETN(I2) == 0)THEN
          FFD=0.5_SP*(WQM(I1,K,N1)+WQM(I,K,N1)           &
	      -WMEAN(I1,K,N1)-WMEAN(I,K,N1))
          FF1=0.5_SP*(WQM(I1,K,N1)+WQM(I,K,N1))
	 ELSE IF(ISWETN(I1) == 0 .AND. ISWETN(I2) == 0)THEN
          FFD=0.5_SP*(WQM(I,K,N1)+WQM(I,K,N1)            &
	      -WMEAN(I,K,N1)-WMEAN(I,K,N1))
          FF1=0.5_SP*(WQM(I,K,N1)+WQM(I,K,N1))
	 ELSE
          FFD=0.5_SP*(WQM(I1,K,N1)+WQM(I2,K,N1)          &
	      -WMEAN(I1,K,N1)-WMEAN(I2,K,N1))
          FF1=0.5_SP*(WQM(I1,K,N1)+WQM(I2,K,N1))
	 END IF 
#    else	 
           FFD=0.5_SP*(WQM(I1,K,N1)+WQM(I2,K,N1)          &
               -WMEAN(I1,K,N1)-WMEAN(I2,K,N1))
           FF1=0.5_SP*(WQM(I1,K,N1)+WQM(I2,K,N1))
#    endif	 
	 
#          if defined (SPHERICAL)
           XTMP  = VX(I2)*TPI-VX(I1)*TPI
           XTMP1 = VX(I2)-VX(I1)
	   IF(XTMP1 >  180.0_SP)THEN
	     XTMP = -360.0_SP*TPI+XTMP
	   ELSE IF(XTMP1 < -180.0_SP)THEN
	     XTMP =  360.0_SP*TPI+XTMP
	   END IF  
           TXPI=XTMP*COS(DEG2RAD*VY(I))
           TYPI=(VY(I1)-VY(I2))*TPI
           PFPX(I)=PFPX(I)+FF1*TYPI
           PFPY(I)=PFPY(I)+FF1*TXPI
           PFPXD(I)=PFPXD(I)+FFD*TYPI
           PFPYD(I)=PFPYD(I)+FFD*TXPI
#          else
           PFPX(I)=PFPX(I)+FF1*(VY(I1)-VY(I2))
           PFPY(I)=PFPY(I)+FF1*(VX(I2)-VX(I1))
           PFPXD(I)=PFPXD(I)+FFD*(VY(I1)-VY(I2))
           PFPYD(I)=PFPYD(I)+FFD*(VX(I2)-VX(I1))
#          endif
         END DO
         PFPX(I)=PFPX(I)/ART2(I)
         PFPY(I)=PFPY(I)/ART2(I)
         PFPXD(I)=PFPXD(I)/ART2(I)
         PFPYD(I)=PFPYD(I)/ART2(I)
       END DO

       DO I=1,M
!         PUPX(I) = 0.0_SP 
!         PUPY(I) = 0.0_SP
!         PVPX(I) = 0.0_SP
!         PVPY(I) = 0.0_SP
!         J=1
!         I1=NBVE(I,J)
!         JTMP=NBVT(I,J)
!         J1=JTMP+1-(JTMP+1)/4*3
!         J2=JTMP+2-(JTMP+2)/4*3
!         X11=0.5_SP*(VX(I)+VX(NV(I1,J1)))
!         Y11=0.5_SP*(VY(I)+VY(NV(I1,J1)))
!         X22=XC(I1)
!         Y22=YC(I1)
!         X33=0.5_SP*(VX(I)+VX(NV(I1,J2)))
!         Y33=0.5_SP*(VY(I)+VY(NV(I1,J2)))
      
!#        if defined (SPHERICAL)
!         X1_DP=VX(I)
!         Y1_DP=VY(I)
!         X2_DP=VX(NV(I1,J1))
!         Y2_DP=VY(NV(I1,J1))
!         CALL ARCC(X2_DP,Y2_DP,X1_DP,Y1_DP,X11_TMP,Y11_TMP)
!         X11=X11_TMP
!         Y11=Y11_TMP
!         X2_DP=VX(NV(I1,J2))
!         Y2_DP=VY(NV(I1,J2))
!         CALL ARCC(X2_DP,Y2_DP,X1_DP,Y1_DP,X33_TMP,Y33_TMP)
!         X33=X33_TMP
!         Y33=Y33_TMP

!         XTMP  = X33*TPI-X11*TPI
!         XTMP1 = X33-X11
!         IF(XTMP1 >  180.0_SP)THEN
!           XTMP = -360.0_SP*TPI+XTMP
!         ELSE IF(XTMP1 < -180.0_SP)THEN
!           XTMP =  360.0_SP*TPI+XTMP
!         END IF	 
!         TXPI=XTMP*COS(DEG2RAD*VY(I))
!         TYPI=(Y11-Y33)*TPI
!         PUPX(I)=PUPX(I)+U(I1,K)*typi
!         PUPY(I)=PUPY(I)+U(I1,K)*txpi
!         PVPX(I)=PVPX(I)+V(I1,K)*typi
!         PVPY(I)=PVPY(I)+V(I1,K)*txpi
!#      else
!         PUPX(I)=PUPX(I)+U(I1,K)*(Y11-Y33)
!         PUPY(I)=PUPY(I)+U(I1,K)*(X33-X11)
!         PVPX(I)=PVPX(I)+V(I1,K)*(Y11-Y33)
!         PVPY(I)=PVPY(I)+V(I1,K)*(X33-X11)
!#      endif

!         IF(ISONB(I) /= 0) THEN
!#          if defined (SPHERICAL)
!           XTMP  = X11*TPI-VX(I)*TPI
!           XTMP1 = X11-VX(I)
!           IF(XTMP1 >  180.0_SP)THEN
!	     XTMP = -360.0_SP*TPI+XTMP
!           ELSE IF(XTMP1 < -180.0_SP)THEN
!	     XTMP =  360.0_SP*TPI+XTMP
!           END IF  
!           TXPI=XTMP*COS(DEG2RAD*VY(I))
!           TYPI=(VY(I)-Y11)*TPI
!           PUPX(I)=PUPX(I)+U(I1,K)*typi
!           PUPY(I)=PUPY(I)+U(I1,K)*txpi
!           PVPX(I)=PVPX(I)+V(I1,K)*typi
!           PVPY(I)=PVPY(I)+V(I1,K)*txpi
!#          else
!           PUPX(I)=PUPX(I)+U(I1,K)*(VY(I)-Y11)
!           PUPY(I)=PUPY(I)+U(I1,K)*(X11-VX(I))
!           PVPX(I)=PVPX(I)+V(I1,K)*(VY(I)-Y11)
!           PVPY(I)=PVPY(I)+V(I1,K)*(X11-VX(I))
!#          endif
!         END IF

!         DO J=2,NTVE(I)-1
!           I1=NBVE(I,J)
!           JTMP=NBVT(I,J)
!           J1=JTMP+1-(JTMP+1)/4*3
!           J2=JTMP+2-(JTMP+2)/4*3
!           X11=0.5_SP*(VX(I)+VX(NV(I1,J1)))
!           Y11=0.5_SP*(VY(I)+VY(NV(I1,J1)))
!           X22=XC(I1)
!           Y22=YC(I1)
!           X33=0.5_SP*(VX(I)+VX(NV(I1,J2)))
!           Y33=0.5_SP*(VY(I)+VY(NV(I1,J2)))

!#          if defined (SPHERICAL)
!           X1_DP=VX(I)
!           Y1_DP=VY(I)
!           X2_DP=VX(NV(I1,J1))
!           Y2_DP=VY(NV(I1,J1))
!           CALL ARCC(X2_DP,Y2_DP,X1_DP,Y1_DP,X11_TMP,Y11_TMP)
!  	   X11=X11_TMP
!	   Y11=Y11_TMP
!           X2_DP=VX(NV(I1,J2))
!           Y2_DP=VY(NV(I1,J2))
!           CALL ARCC(X2_DP,Y2_DP,X1_DP,Y1_DP,X33_TMP,Y33_TMP)
!	   X33=X33_TMP
!	   Y33=Y33_TMP

!           XTMP  = X33*TPI-X11*TPI
!           XTMP1 = X33-X11
!           IF(XTMP1 >  180.0_SP)THEN
!	     XTMP = -360.0_SP*TPI+XTMP
!           ELSE IF(XTMP1 < -180.0_SP)THEN
!	     XTMP =  360.0_SP*TPI+XTMP
!  	   END IF  
!           TXPI=XTMP*COS(DEG2RAD*VY(I))
!           TYPI=(Y11-Y33)*TPI
!           PUPX(I)=PUPX(I)+U(I1,K)*typi
!           PUPY(I)=PUPY(I)+U(I1,K)*txpi
!           PVPX(I)=PVPX(I)+V(I1,K)*typi
!           PVPY(I)=PVPY(I)+V(I1,K)*txpi
!#          else
!           PUPX(I)=PUPX(I)+U(I1,K)*(Y11-Y33)
!           PUPY(I)=PUPY(I)+U(I1,K)*(X33-X11)
!           PVPX(I)=PVPX(I)+V(I1,K)*(Y11-Y33)
!           PVPY(I)=PVPY(I)+V(I1,K)*(X33-X11)
!#          endif
!         END DO
!         J=NTVE(I)
!         I1=NBVE(I,J)
!         JTMP=NBVT(I,J)
!         J1=JTMP+1-(JTMP+1)/4*3
!         J2=JTMP+2-(JTMP+2)/4*3
!         X11=0.5_SP*(VX(I)+VX(NV(I1,J1)))
!         Y11=0.5_SP*(VY(I)+VY(NV(I1,J1)))
!         X22=XC(I1)
!         Y22=YC(I1)
!         X33=0.5_SP*(VX(I)+VX(NV(I1,J2)))
!         Y33=0.5_SP*(VY(I)+VY(NV(I1,J2)))

!#        if defined (SPHERICAL)
!         X1_DP=VX(I)
!         Y1_DP=VY(I)
!         X2_DP=VX(NV(I1,J1))
!         Y2_DP=VY(NV(I1,J1))
!         CALL ARCC(X2_DP,Y2_DP,X1_DP,Y1_DP,X11_TMP,Y11_TMP)
!         X11=X11_TMP
!         Y11=Y11_TMP
!         X2_DP=VX(NV(I1,J2))
!         Y2_DP=VY(NV(I1,J2))
!         CALL ARCC(X2_DP,Y2_DP,X1_DP,Y1_DP,X33_TMP,Y33_TMP)
!         X33=X33_TMP
!         Y33=Y33_TMP

!         XTMP  = X33*TPI-X11*TPI
!         XTMP1 = X33-X11
!         IF(XTMP1 >  180.0_SP)THEN
!           XTMP = -360.0_SP*TPI+XTMP
!         ELSE IF(XTMP1 < -180.0_SP)THEN
!           XTMP =  360.0_SP*TPI+XTMP
!         END IF	 
!         TXPI=XTMP*COS(DEG2RAD*VY(I))
!         typi=(y11-y33)*TPI
!         pupx(i)=pupx(i)+u(i1,k)*typi
!         pupy(i)=pupy(i)+u(i1,k)*txpi
!         pvpx(i)=pvpx(i)+v(i1,k)*typi
!         pvpy(i)=pvpy(i)+v(i1,k)*txpi
!#        else
!         PUPX(I)=PUPX(I)+U(I1,K)*(Y11-Y33)
!         PUPY(I)=PUPY(I)+U(I1,K)*(X33-X11)
!         PVPX(I)=PVPX(I)+V(I1,K)*(Y11-Y33)
!         PVPY(I)=PVPY(I)+V(I1,K)*(X33-X11)
!#        endif

!         IF(ISONB(I) /= 0) THEN
!#          if defined (SPHERICAL)
!           TY=0.5*(y11+vy(i))
!           XTMP  = VX(I)*TPI-X11*TPI
!           XTMP1 = VX(I)-X11
!           IF(XTMP1 >  180.0_SP)THEN
!	     XTMP = -360.0_SP*TPI+XTMP
!           ELSE IF(XTMP1 < -180.0_SP)THEN
!	     XTMP =  360.0_SP*TPI+XTMP
!	   END IF  
!           TXPI=XTMP*COS(DEG2RAD*VY(I))
!           typi=(y11-vy(i))*TPI
!           PUPX(I)=PUPX(I)+U(I1,K)*typi
!           PUPY(I)=PUPY(I)+U(I1,K)*txpi
!           PVPX(I)=PVPX(I)+V(I1,K)*typi
!           PVPY(I)=PVPY(I)+V(I1,K)*txpi
!#          else
!           PUPX(I)=PUPX(I)+U(I1,K)*(Y11-VY(I))
!           PUPY(I)=PUPY(I)+U(I1,K)*(VX(I)-X11)
!           PVPX(I)=PVPX(I)+V(I1,K)*(Y11-VY(I))
!           PVPY(I)=PVPY(I)+V(I1,K)*(VX(I)-X11)
!#          endif
!         END IF
!         PUPX(I)=PUPX(I)/ART1(I)
!         PUPY(I)=PUPY(I)/ART1(I)
!         PVPX(I)=PVPX(I)/ART1(I)
!         PVPY(I)=PVPY(I)/ART1(I)
!         TMP1=PUPX(I)**2+PVPY(I)**2
!         TMP2=0.5_SP*(PUPY(I)+PVPX(I))**2
!         VISCOFF(I)=SQRT(TMP1+TMP2)*ART1(I)
       
       VISCOFF(I)=VISCOFH(I,K)
       
       END DO

       DO I=1,NCV_I
         IA=NIEC(I,1)
         IB=NIEC(I,2)
         XI=0.5_SP*(XIJE(I,1)+XIJE(I,2))
         YI=0.5_SP*(YIJE(I,1)+YIJE(I,2))
#        if defined (SPHERICAL)
         X1_DP=XIJE(I,1)
         Y1_DP=YIJE(I,1)
         X2_DP=XIJE(I,2)
         Y2_DP=YIJE(I,2)
         CALL ARCC(X2_DP,Y2_DP,X1_DP,Y1_DP,XII,YII)
         XI=XII		
         XTMP  = XI*TPI-VX(IA)*TPI
         XTMP1 = XI-VX(IA)
         IF(XTMP1 >  180.0_SP)THEN
           XTMP = -360.0_SP*TPI+XTMP
         ELSE IF(XTMP1 < -180.0_SP)THEN
           XTMP =  360.0_SP*TPI+XTMP
         END IF	 
         DXA=XTMP*COS(DEG2RAD*VY(IA))   
         dya=(yi-vy(ia))*TPI
         TY=0.5*(yi+vy(ib))
         XTMP  = XI*TPI-VX(IB)*TPI
         XTMP1 = XI-VX(IB)
         IF(XTMP1 >  180.0_SP)THEN
           XTMP = -360.0_SP*TPI+XTMP
         ELSE IF(XTMP1 < -180.0_SP)THEN
           XTMP =  360.0_SP*TPI+XTMP
         END IF	 
         DXB=XTMP*COS(DEG2RAD*VY(IB))  
         dyb=(yi-vy(ib))*TPI
#        else
         DXA=XI-VX(IA)
         DYA=YI-VY(IA)
         DXB=XI-VX(IB)
         DYB=YI-VY(IB)
#        endif
         FIJ1=WQM(IA,K,N1)+DXA*PFPX(IA)+DYA*PFPY(IA)
         FIJ2=WQM(IB,K,N1)+DXB*PFPX(IB)+DYB*PFPY(IB)

         WQM1MIN=MINVAL(WQM(NBSN(IA,1:NTSN(IA)-1),K,N1))
         WQM1MIN=MIN(WQM1MIN, WQM(IA,K,N1))
         WQM1MAX=MAXVAL(WQM(NBSN(IA,1:NTSN(IA)-1),K,N1))
         WQM1MAX=MAX(WQM1MAX, WQM(IA,K,N1))
         WQM2MIN=MINVAL(WQM(NBSN(IB,1:NTSN(IB)-1),K,N1))
         WQM2MIN=MIN(WQM2MIN, WQM(IB,K,N1))
         WQM2MAX=MAXVAL(WQM(NBSN(IB,1:NTSN(IB)-1),K,N1))
         WQM2MAX=MAX(WQM2MAX, WQM(IB,K,N1))
         IF(FIJ1 < WQM1MIN) FIJ1=WQM1MIN
         IF(FIJ1 > WQM1MAX) FIJ1=WQM1MAX
         IF(FIJ2 < WQM2MIN) FIJ2=WQM2MIN
         IF(FIJ2 > WQM2MAX) FIJ2=WQM2MAX
    
         UN=UVN(I,K)
  
         VISCOF=HORCON*(FACT*(VISCOFF(IA)+VISCOFF(IB))*0.5_SP + FM1)

         TXX=0.5_SP*(PFPXD(IA)+PFPXD(IB))*VISCOF
         TYY=0.5_SP*(PFPYD(IA)+PFPYD(IB))*VISCOF

         FXX=-DTIJ(I,K)*TXX*DLTYE(I)
         FYY= DTIJ(I,K)*TYY*DLTXE(I)

         EXFLUX=-UN*DTIJ(I,K)*                             &
                ((1.0_SP+SIGN(1.0_SP,UN))*FIJ2+          &
                 (1.0_SP-SIGN(1.0_SP,UN))*FIJ1)*0.5_SP   &
                +FXX+FYY
 
         XFLUX(IA,K,N1)=XFLUX(IA,K,N1)+EXFLUX
         XFLUX(IB,K,N1)=XFLUX(IB,K,N1)-EXFLUX
       END DO
     END DO
   END DO

!
!-Accumulate Fluxes at Boundary Nodes
!
# if defined (MULTIPROCESSOR)
     IF(PAR)CALL NODE_MATCH(0,NBN,BN_MLT,BN_LOC,BNC,MT,KB,MYID,NPROCS,       &
                            XFLUX(:,:,1),XFLUX(:,:,2),XFLUX(:,:,3))
     IF(PAR)CALL NODE_MATCH(0,NBN,BN_MLT,BN_LOC,BNC,MT,KB,MYID,NPROCS,       &
                            XFLUX(:,:,4),XFLUX(:,:,5),XFLUX(:,:,6))
     IF(PAR)CALL NODE_MATCH(0,NBN,BN_MLT,BN_LOC,BNC,MT,KB,MYID,NPROCS,       &
                            XFLUX(:,:,7),XFLUX(:,:,8))
# endif


   DO N1=1,NB
#  if defined (MPDATA)
!--------------------------------------------------------------------------------
!   S. HU
!   Using smolarkiewicz, P. K; A fully multidimensional positive definite advection
!   transport algorithm with small implicit diffusion, Journal of Computational
!   Physics, 54, 325-362, 1984
!-----------------------------------------------------------------        
!
!--Set Boundary Conditions-For Fresh Water Flux--------------------------------!
!
     WQM_FRESH = WQM(:,:,N1)
     
     IF(POINT_ST_TYPE == 'calculated') THEN
       IF(INFLOW_TYPE == 'node') THEN
         IF(NUMQBC > 0) THEN
           DO J=1,NUMQBC
             JJ=INODEQ(J)
             STPOINT=WDIS(J,N1)
             DO K=1,KBM1
               XFLUX(JJ,K,N1)=XFLUX(JJ,K,N1) - QDIS(J)*VQDIST(J,K)*STPOINT   !/DZ(K)
             END DO
           END DO
         END IF
       ELSE IF(INFLOW_TYPE == 'edge') THEN
         IF(NUMQBC > 0) THEN
           DO J=1,NUMQBC
             J1=N_ICELLQ(J,1)
             J2=N_ICELLQ(J,2)
             STPOINT=WDIS(J,N1) !!ASK LIU SHOULD THIS BE STPOINT1(J1)/STPOINT2(J2)
             DO K=1,KBM1
               XFLUX(J1,K,N1)=XFLUX(J1,K,N1)-QDIS(J)*RDISQ(J,1)*VQDIST(J,K)*STPOINT   !/DZ(K)
               XFLUX(J2,K,N1)=XFLUX(J2,K,N1)-QDIS(J)*RDISQ(J,2)*VQDIST(J,K)*STPOINT   !/DZ(K)
             END DO
           END DO
         END IF
       END IF
     END IF


! The horizontal term of advection is neglected here
   DO K=1,KBM1
     DO I=1,M
       IF(ISONB(I) == 2) THEN
         XFLUX(I,K,N1)=0.
       ENDIF
     END DO
   END DO

! Initialize variables of MPDATA
   WQM_S=0._SP
   WQM_SF=0._SP
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
           TEMP = -(WTS(I,K+1)-ABS(WTS(I,K+1)))*WQM(I,K,N1)   &
                  -(WTS(I,K+1)+ABS(WTS(I,K+1)))*WQM(I,K+1,N1) &
                  +(WTS(I,K)+ABS(WTS(I,K)))*WQM(I,K,N1)    
         ELSE IF(K == KBM1) THEN
           TEMP = +(WTS(I,K)-ABS(WTS(I,K)))*WQM(I,K-1,N1)     &
                  +(WTS(I,K)+ABS(WTS(I,K)))*WQM(I,K,N1)
         ELSE
           TEMP = -(WTS(I,K+1)-ABS(WTS(I,K+1)))*WQM(I,K,N1)   &
                  -(WTS(I,K+1)+ABS(WTS(I,K+1)))*WQM(I,K+1,N1) &
                  +(WTS(I,K)-ABS(WTS(I,K)))*WQM(I,K-1,N1)     &
                  +(WTS(I,K)+ABS(WTS(I,K)))*WQM(I,K,N1)
         END IF
         TEMP = 0.5_SP*TEMP 

         IF(K == 1)THEN
           WQMMAX = MAXVAL(WQM(NBSN(I,1:NTSN(I)),K,N1))
           WQMMIN = MINVAL(WQM(NBSN(I,1:NTSN(I)),K,N1))
           WQMMAX = MAX(WQMMAX,WQM(I,K+1,N1),WQM(I,K,N1),WQM_FRESH(I,K))
           WQMMIN = MIN(WQMMIN,WQM(I,K+1,N1),WQM(I,K,N1),WQM_FRESH(I,K))
         ELSEIF(K == KBM1)THEN
           WQMMAX = MAXVAL(WQM(NBSN(I,1:NTSN(I)),K,N1))
           WQMMIN = MINVAL(WQM(NBSN(I,1:NTSN(I)),K,N1))
           WQMMAX = MAX(WQMMAX,WQM(I,K-1,N1),WQM(I,K,N1),WQM_FRESH(I,K))
           WQMMIN = MIN(WQMMIN,WQM(I,K-1,N1),WQM(I,K,N1),WQM_FRESH(I,K))
         ELSE
           WQMMAX = MAXVAL(WQM(NBSN(I,1:NTSN(I)),K,N1))
           WQMMIN = MINVAL(WQM(NBSN(I,1:NTSN(I)),K,N1))
           WQMMAX = MAX(WQMMAX,WQM(I,K+1,N1),WQM(I,K-1,N1),WQM(I,K,N1),WQM_FRESH(I,K))
           WQMMIN = MIN(WQMMIN,WQM(I,K+1,N1),WQM(I,K-1,N1),WQM(I,K,N1),WQM_FRESH(I,K))
         END IF

         ZZZFLUX(I,K) = TEMP*(DTI/DT(I))/DZ(I,K) + XFLUX(I,K,N1)/ART1(I)*(DTI/DT(I))/DZ(I,K) 
         XXXX = ZZZFLUX(I,K)*DT(I)/DTFA(I)+WQM(I,K,N1)-WQM(I,K,N1)*DT(I)/DTFA(I) 

         BETA(I,K)=0.5*(1.-SIGN(1.,XXXX)) * (WQMMAX-WQM(I,K,N1))/(ABS(XXXX)+1.E-10) &
                  +0.5*(1.-SIGN(1.,-XXXX)) * (WQM(I,K,N1)-WQMMIN)/(ABS(XXXX)+1.E-10)

         WQM_SF(I,K)=WQM(I,K,N1)-MIN(1.,BETA(I,K))*XXXX

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
       WQM_S   = WQM_SF
       DTWWWS = DT
     ELSE
       WWWSF  = WWWS
       WQM_S   = WQM_SF
       DTWWWS = DTFA
     END IF
     DO K=2,KBM1
       DO I=1,M
         TEMP=ABS(WWWSF(I,K))-DTI*(WWWSF(I,K))*(WWWSF(I,K))/DZ(I,K)/DTWWWS(I)
         WWWS(I,K)=TEMP*(WQM_S(I,K-1)-WQM_S(I,K))/(ABS(WQM_S(I,K-1))+ABS(WQM_S(I,K))+1.E-14)
 
         IF(TEMP < 0.0_SP .OR. WQM_S(I,K) == 0.0_SP)THEN 
           WWWS(I,K)=0. 
         END IF
       END DO 
     END DO
     DO I=1,M
       WWWS(I,1)=0.
     END DO

     DO I=1,M
       WQMMAX = MAXVAL(WQM(NBSN(I,1:NTSN(I)),1,N1))
       WQMMIN = MINVAL(WQM(NBSN(I,1:NTSN(I)),1,N1))
       WQMMAX = MAX(WQMMAX,WQM(I,2,N1),WQM(I,1,N1),WQM_FRESH(I,1))
       WQMMIN = MIN(WQMMIN,WQM(I,2,N1),WQM(I,1,N1),WQM_FRESH(I,1))
 
       TEMP=0.5*((WWWS(I,2)+ABS(WWWS(I,2)))*WQM_S(I,2))*(DTI/DTFA(I))/DZ(I,1)
       BETAIN(I,1)=(WQMMAX-WQM_S(I,1))/(TEMP+1.E-10)

       TEMP=0.5*((WWWS(I,1)+ABS(WWWS(I,1)))*WQM_S(I,1)-        &
	           (WWWS(I,2)-ABS(WWWS(I,2)))*WQM_S(I,1))*(DTI/DTFA(I))/DZ(I,1)
       BETAOUT(I,1)=(WQM_S(I,1)-WQMMIN)/(TEMP+1.E-10)

       WWWSF(I,1)=0.5*MIN(1.,BETAOUT(I,1))*(WWWS(I,1)+ABS(WWWS(I,1))) + &
                    0.5*MIN(1.,BETAIN(I,1))*(WWWS(I,1)-ABS(WWWS(I,1)))
     END DO

     DO K=2,KBM1-1
       DO I=1,M
         WQMMAX = MAXVAL(WQM(NBSN(I,1:NTSN(I)),K,N1))
         WQMMIN = MINVAL(WQM(NBSN(I,1:NTSN(I)),K,N1))
         WQMMAX = MAX(WQMMAX,WQM(I,K+1,N1),WQM(I,K-1,N1),WQM(I,K,N1),WQM_FRESH(I,K))
         WQMMIN = MIN(WQMMIN,WQM(I,K+1,N1),WQM(I,K-1,N1),WQM(I,K,N1),WQM_FRESH(I,K))
 
         TEMP=0.5*((WWWS(I,K+1)+ABS(WWWS(I,K+1)))*WQM_S(I,K+1)-  &
	           (WWWS(I,K)-ABS(WWWS(I,K)))*WQM_S(I,K-1))*(DTI/DTFA(I))/DZ(I,K)
         BETAIN(I,K)=(WQMMAX-WQM_S(I,K))/(TEMP+1.E-10)

         TEMP=0.5*((WWWS(I,K)+ABS(WWWS(I,K)))*WQM_S(I,K)-        &
	           (WWWS(I,K+1)-ABS(WWWS(I,K+1)))*WQM_S(I,K))*(DTI/DTFA(I))/DZ(I,K)
         BETAOUT(I,K)=(WQM_S(I,K)-WQMMIN)/(TEMP+1.E-10)

         WWWSF(I,K)=0.5*MIN(1.,BETAIN(I,K-1),BETAOUT(I,K))*(WWWS(I,K)+ABS(WWWS(I,K))) + &
                    0.5*MIN(1.,BETAIN(I,K),BETAOUT(I,K-1))*(WWWS(I,K)-ABS(WWWS(I,K)))
       END DO
     END DO

     K=KBM1
     DO I=1,M
       WQMMAX = MAXVAL(WQM(NBSN(I,1:NTSN(I)),K,N1))
       WQMMIN = MINVAL(WQM(NBSN(I,1:NTSN(I)),K,N1))
       WQMMAX = MAX(WQMMAX,WQM(I,K-1,N1),WQM(I,K,N1),WQM_FRESH(I,K))
       WQMMIN = MIN(WQMMIN,WQM(I,K-1,N1),WQM(I,K,N1),WQM_FRESH(I,K))
 
       TEMP=0.5*((WWWS(I,K+1)+ABS(WWWS(I,K+1)))*WQM_S(I,K+1)-  &
	         (WWWS(I,K)-ABS(WWWS(I,K)))*WQM_S(I,K-1))*(DTI/DTFA(I))/DZ(I,K)
       BETAIN(I,K)=(WQMMAX-WQM_S(I,K))/(TEMP+1.E-10)

       TEMP=0.5*((WWWS(I,K)+ABS(WWWS(I,K)))*WQM_S(I,K)-        &
	         (WWWS(I,K+1)-ABS(WWWS(I,K+1)))*WQM_S(I,K))*(DTI/DTFA(I))/DZ(I,K)
       BETAOUT(I,K)=(WQM_S(I,K)-WQMMIN)/(TEMP+1.E-10)

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
             TEMP = -(WWWS(I,K+1)-ABS(WWWS(I,K+1)))*WQM_S(I,K)   &
                    -(WWWS(I,K+1)+ABS(WWWS(I,K+1)))*WQM_S(I,K+1) &
                    +(WWWS(I,K)+ABS(WWWS(I,K)))*WQM_S(I,K)
           ELSE IF(K == KBM1) THEN
             TEMP = +(WWWS(I,K)-ABS(WWWS(I,K)))*WQM_S(I,K-1)     &
                    +(WWWS(I,K)+ABS(WWWS(I,K)))*WQM_S(I,K)
           ELSE
             TEMP = -(WWWS(I,K+1)-ABS(WWWS(I,K+1)))*WQM_S(I,K)   &
                    -(WWWS(I,K+1)+ABS(WWWS(I,K+1)))*WQM_S(I,K+1) &
                    +(WWWS(I,K)-ABS(WWWS(I,K)))*WQM_S(I,K-1)     &
                    +(WWWS(I,K)+ABS(WWWS(I,K)))*WQM_S(I,K)
           END IF
           TEMP = 0.5_SP*TEMP
           WQM_SF(I,K)=(WQM_S(I,K)-TEMP*(DTI/DTFA(I))/DZ(I,K)) 
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


#  if !defined (MPDATA)
!
!--Calculate the Vertical Terms------------------------------------------------
!
     DO K=1,KBM1
       DO I=1,M
#      if defined (WET_DRY)
       IF(ISWETN(I)*ISWETNT(I) == 1) THEN
#      endif
         IF(K == 1) THEN
           TEMP=-WTS(I,K+1)*(WQM(I,K,N1)*DZ(I,K+1)+WQM(I,K+1,N1)*DZ(I,K))/   &
	       (DZ(I,K)+DZ(I,K+1))
         ELSE IF(K == KBM1) THEN
           TEMP=WTS(I,K)*(WQM(I,K,N1)*DZ(I,K-1)+WQM(I,K-1,N1)*DZ(I,K))/   &
	       (DZ(I,K)+DZ(I,K-1))
         ELSE
           TEMP=WTS(I,K)*(WQM(I,K,N1)*DZ(I,K-1)+WQM(I,K-1,N1)*DZ(I,K))/  &
	       (DZ(I,K)+DZ(I,K-1))-  &
                WTS(I,K+1)*(WQM(I,K,N1)*DZ(I,K+1)+WQM(I,K+1,N1)*DZ(I,K))/  &
	       (DZ(I,K)+DZ(I,K+1))
         END IF

!
!--Total Fluxes ---------------------------------------------------------------
!
         IF(ISONB(I) == 2) THEN
!           XFLUX(I,K,N1)=TEMP*ART1(I)/DZ(K)
           XFLUX(I,K,N1)=TEMP*ART1(I)
         ELSE
!           XFLUX(I,K,N1)=XFLUX(I,K,N1)+TEMP*ART1(I)/DZ(K)
            XFLUX(I,K,N1)=XFLUX(I,K,N1)+TEMP*ART1(I)
        END IF
#    if defined (WET_DRY)
       END IF
#    endif
       END DO
     END DO

!
!--Set Boundary Conditions-For Fresh Water Flux--------------------------------!
!
     IF(POINT_ST_TYPE == 'calculated') THEN
       IF(INFLOW_TYPE == 'node') THEN
         IF(NUMQBC > 0) THEN
           DO J=1,NUMQBC
             JJ=INODEQ(J)
             STPOINT=WDIS(J,N1)
             DO K=1,KBM1
!               XFLUX(JJ,K,N1)=XFLUX(JJ,K,N1) - QDIS(J)*VQDIST(J,K)*STPOINT/DZ(K)
               XFLUX(JJ,K,N1)=XFLUX(JJ,K,N1) - QDIS(J)*VQDIST(J,K)*STPOINT
             END DO
           END DO
         END IF
       ELSE IF(INFLOW_TYPE == 'edge') THEN
         IF(NUMQBC > 0) THEN
           DO J=1,NUMQBC
             J1=N_ICELLQ(J,1)
             J2=N_ICELLQ(J,2)
             STPOINT=WDIS(J,N1) !!ASK LIU SHOULD THIS BE STPOINT1(J1)/STPOINT2(J2)
             DO K=1,KBM1
!               XFLUX(J1,K,N1)=XFLUX(J1,K,N1)-QDIS(J)*RDISQ(J,1)*VQDIST(J,K)*STPOINT/DZ(K)
!               XFLUX(J2,K,N1)=XFLUX(J2,K,N1)-QDIS(J)*RDISQ(J,2)*VQDIST(J,K)*STPOINT/DZ(K)
               XFLUX(J1,K,N1)=XFLUX(J1,K,N1)-QDIS(J)*RDISQ(J,1)*VQDIST(J,K)*STPOINT
               XFLUX(J2,K,N1)=XFLUX(J2,K,N1)-QDIS(J)*RDISQ(J,2)*VQDIST(J,K)*STPOINT
             END DO
           END DO
         END IF
       END IF
     END IF

#  endif
!
!--Update Water Quality Variables--------------------------------
!
     DO I = 1,M
#    if defined (WET_DRY)
       IF(ISWETN(I)*ISWETNT(I) == 1 )THEN
#      endif
         DO K = 1, KBM1
#        if !defined (MPDATA)     
!           WQM_F(I,K,N1)=(WQM(I,K,N1)-XFLUX(I,K,N1)/ART1(I)*(DTI/DT(I)))*   &
!                         (DT(I)/D(I))+RF(I,K,N1)*DTI
           WQM_F(I,K,N1)=(WQM(I,K,N1)-XFLUX(I,K,N1)/ART1(I)*(DTI/(DT(I)*DZ(I,K))))*   &
                         (DT(I)/D(I))+RF(I,K,N1)*DTI
#        else
           WQM_F(I,K,N1)=WQM_SF(I,K)   !-XFLUX(I,K,N1)/ART1(I)*DTI/DTFA(I)
#    endif              
         END DO
#      if defined (WET_DRY)
       ELSE
         DO K=1,KBM1
           WQM_F(I,K,N1)=WQM(I,K,N1)
         END DO
       END IF
#      endif
     END DO

   END DO

   RETURN
   END SUBROUTINE ADV_WQM
!==============================================================================!

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

   SUBROUTINE BCOND_WQM     
!==============================================================================|
!   Set Boundary Conditions on Water Quality                                   |
!==============================================================================|

!------------------------------------------------------------------------------|
   USE ALL_VARS
   USE BCS
   USE MOD_OBCS
   IMPLICIT NONE
   REAL(SP) :: T2D,T2D_NEXT,T2D_OBC,XFLUX2D,TMP
   INTEGER  :: I,J,K,J1,J11,J22,NCON2,N1
   REAL(SP) ::WQMMAX,WQMMIN
!------------------------------------------------------------------------------|


!
!--SET CONDITIONS FOR FRESH WATER INFLOW---------------------------------------|
!
   IF(POINT_ST_TYPE == 'specified') THEN
     IF(NUMQBC > 0) THEN
       IF(INFLOW_TYPE == 'node') THEN
         DO I=1,NUMQBC
           J11=INODEQ(I)
           DO K=1,KBM1
             DO N1=1,NB
               WQM_F(J11,K,N1) = WDIS(I,N1)
             END DO
           END DO
         END DO
       ELSE IF(INFLOW_TYPE == 'edge') THEN
         DO I=1,NUMQBC
           J11=N_ICELLQ(I,1)
           J22=N_ICELLQ(I,2)
           DO K=1,KBM1
             DO N1=1,NB
               WQM_F(J11,K,N1)=WDIS(I,N1)
               WQM_F(J22,K,N1)=WDIS(I,N1)
             END DO
           END DO
         END DO
       END IF
     END IF
   END IF

       
   IF(IOBCN > 0) THEN

!
!  SET WATER QUALITY CONDITIONS ON OUTER BOUNDARY
!
     DO N1=1,NB
       DO I=1,IOBCN
         J=I_OBC_N(I)
         J1=NEXT_OBC(I)
         T2D=0.0_SP
         T2D_NEXT=0.0_SP
         XFLUX2D=0.0_SP
         DO K=1,KBM1
           T2D=T2D+WQM(J,K,N1)*DZ(J,K)
           T2D_NEXT=T2D_NEXT+WQM_F(J1,K,N1)*DZ(J1,K)
           XFLUX2D=XFLUX2D+XFLUX_OBC(I,K)                             !*DZ(K)
         END DO
    
         IF(UARD_OBCN(I) > 0.0_SP) THEN
           TMP=XFLUX2D+T2D*UARD_OBCN(I)
           T2D_OBC=(T2D*DT(J)-TMP*DTI/ART1(J))/D(J)
           DO K=1,KBM1
             WQM_F(J,K,N1)=T2D_OBC+(WQM_F(J1,K,N1)-T2D_NEXT)
!             WQM_F(J,K,N1) = WQM_F(J1,K,N1)
           END DO

         DO K=1,KBM1
           WQMMAX = MAXVAL(WQM(NBSN(J,1:NTSN(J)),K,N1))
           WQMMIN = MINVAL(WQM(NBSN(J,1:NTSN(J)),K,N1))
         
           IF(K == 1)THEN
            WQMMAX = MAX(WQMMAX,(WQM(J,K,N1)*DZ(J,K+1)+WQM(J,K+1,N1)*DZ(J,K))/  &
	             (DZ(J,K)+DZ(J,K+1)))
            WQMMIN = MIN(WQMMIN,(WQM(J,K,N1)*DZ(J,K+1)+WQM(J,K+1,N1)*DZ(J,K))/  &
	             (DZ(J,K)+DZ(J,K+1)))
           ELSE IF(K == KBM1)THEN
            WQMMAX = MAX(WQMMAX,(WQM(J,K,N1)*DZ(J,K-1)+WQM(J,K-1,N1)*DZ(J,K))/  &
	             (DZ(J,K)+DZ(J,K-1)))
            WQMMIN = MIN(WQMMIN,(WQM(J,K,N1)*DZ(J,K-1)+WQM(J,K-1,N1)*DZ(J,K))/  &
	             (DZ(J,K)+DZ(J,K-1)))
           ELSE
            WQMMAX = MAX(WQMMAX,(WQM(J,K,N1)*DZ(J,K-1)+WQM(J,K-1,N1)*DZ(J,K))/  &
	             (DZ(J,K)+DZ(J,K-1)), &
                     (WQM(J,K,N1)*DZ(J,K+1)+WQM(J,K+1,N1)*DZ(J,K))/  &
		     (DZ(J,K)+DZ(J,K+1)))
            WQMMIN = MIN(WQMMIN,(WQM(J,K,N1)*DZ(J,K-1)+WQM(J,K-1,N1)*DZ(J,K))/  &
	             (DZ(J,K)+DZ(J,K-1)), &
                     (WQM(J,K,N1)*DZ(J,K+1)+WQM(J,K+1,N1)*DZ(J,K))/  &
		     (DZ(J,K)+DZ(J,K+1)))
           END IF
 
           IF(WQMMIN-WQM_F(J,K,N1) > 0.0_SP)WQM_F(J,K,N1) = WQMMIN
           IF(WQM_F(J,K,N1)-WQMMAX > 0.0_SP)WQM_F(J,K,N1) = WQMMAX

         END DO

         ELSE
           DO K=1,KBM1
               WQM_F(J,K,N1)=WQM(J,K,N1)
           END DO
         END IF
       END DO
     END DO !!OUTER LOOP OVER WQ VARIABLES


   END IF

!
!--SET BOUNDARY CONDITIONS-----------------------------------------------------|
!
   WQM(0,:,:) = 0.0_SP
!   DO K = 1,KBM1
!     DO N1 = 1,NB
!       WQM(0,K,N1) = 0.0_SP
!     END DO
!   END DO

   RETURN
   END SUBROUTINE BCOND_WQM

!==============================================================================|

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

!==============================================================================|
   SUBROUTINE VDIF_WQM(F)
!==============================================================================!
!									       !
!   This subroutine is used to calculate the eight variables of water 	       !
!   quality model in the Satilla River. They are: 			       !
!     (1) Dissolved Oxygen (DO)						       !
!     (2) Carbonaceous Biochemical Oxygen Demand (CBOD)			       !
!     (3) Phytoplankton (PHYT)						       !
!     (4) Ammonia Nitrogen (NH4)					       !
!     (5) Nitrate and Nitrite Nitrogen (NO3+NO2)			       !
!     (6) Organic Nitrogen (ON) 					       !
!     (7) Orthophosphorus or Inorganic Phosphorus (OPO4) 		       !
!     (8) Organic Phosphorus (OP) 					       !
!									       !
!   This subroutine is used to calculate the true water quality variables      !
!   by including vertical diffusion implicitly.		                       !
! 									       !
!==============================================================================!
 
   USE ALL_VARS
#  if defined (WET_DRY)
   USE MOD_WD
#  endif
   IMPLICIT NONE
   REAL(SP), DIMENSION(0:MT,KB,NB) :: F
   REAL(DP), DIMENSION(M,KB,NB)    :: FF, VHF, VHPF 
   REAL(DP), DIMENSION(M,KB)       :: AF, CF, RAD
   REAL(SP), DIMENSION(M,NB)       :: BENFLUX,WFSURF
   REAL(SP), DIMENSION(M)          :: SOURCE1,SOURCE2,SOURCE3
   REAL(SP), DIMENSION(M)          :: TBOT
   REAL(SP) :: FKH,UMOLPR  
   REAL(SP) :: TEMPWUVBOT,TMP
   INTEGER  :: I,K,J,KI,N1

   UMOLPR = UMOL*1.E0_SP

!--- CALCULATE BOTTOM FLUX TERM --------------------------

   BENFLUX = 0.0_SP

   IF(BENWQM_KEY)THEN
     DO I = 1, M
#  if !defined (WET_DRY)
       IF(D(I) > 0.0_SP) THEN
#  else
       IF(ISWETN(I) == 1)THEN
#  endif
         SOURCE1(I) = 0.0_SP
         SOURCE2(I) = 0.0_SP
         SOURCE3(I) = 0.0_SP

         TEMPWUVBOT = 0.0_SP
         DO J = 1, NTVE(I)
           TMP=SQRT(WUBOT(NBVE(I,J))**2+WVBOT(NBVE(I,J))**2)
           TEMPWUVBOT = TEMPWUVBOT + TMP
         END DO
         TEMPWUVBOT = TEMPWUVBOT/FLOAT(NTVE(I))
         TBOT(I) = TEMPWUVBOT*1.0E+3_SP

         IF(H(I) >= 1.9_SP .AND. TBOT(I) > TCE2) THEN
           SOURCE1(I) = (TBOT(I) - TCE2) * 1.E-3_SP * RSED1(I)
           SOURCE2(I) = (TBOT(I) - TCE2) * 1.E-3_SP * RSED2(I)
           SOURCE3(I) = (TBOT(I) - TCE2) * 1.E-3_SP * RSED3(I)
         ELSE IF(H(I) >= 1.9_SP .AND. TBOT(I) < TCS2) THEN
           SOURCE1(I) = (TBOT(I) - TCS2) * 1.E-3_SP * RSED1(I)
           SOURCE2(I) = (TBOT(I) - TCS2) * 1.E-3_SP * RSED2(I)
           SOURCE3(I) = (TBOT(I) - TCS2) * 1.E-3_SP * RSED3(I)
           SOURCE1(I) = SOURCE1(I) * 0.05_SP
           SOURCE2(I) = SOURCE2(I) * 0.05_SP
           SOURCE3(I) = SOURCE3(I) * 0.05_SP
         END IF

         BENFLUX(I,4) = SOURCE1(I)
         BENFLUX(I,5) = SOURCE2(I)
         BENFLUX(I,7) = SOURCE3(I)

         BENFLUX(I,1) = (-DIFF_Z*(F(I,KB,1)-SEDWQM(I,1))/            &
                        DEP_BEN)/DAY_SEC + BENFLUX(I,1)
         BENFLUX(I,2) = (-DIFF_Z*(F(I,KB,2)*FD2-SEDWQM(I,2)*FDB2)/   &
                        DEP_BEN)/DAY_SEC + BENFLUX(I,2)
         BENFLUX(I,3) = (-DIFF_Z*F(I,KB,3)/DEP_BEN)/DAY_SEC          &
                        + BENFLUX(I,3)
         BENFLUX(I,4) = (-DIFF_Z*(F(I,KB,4)-SEDWQM(I,4)*FDB4)/       &
                        DEP_BEN)/DAY_SEC + BENFLUX(I,4)
         BENFLUX(I,5) = (-DIFF_Z*(F(I,KB,5)-SEDWQM(I,5)*FDB5)/       & 
                        DEP_BEN)/DAY_SEC + BENFLUX(I,5)
         BENFLUX(I,6) = (-DIFF_Z*(F(I,KB,6)*FD6-SEDWQM(I,6)*FDB5)/   &
                        DEP_BEN)/DAY_SEC + BENFLUX(I,6)
         BENFLUX(I,7) = (-DIFF_Z*(F(I,KB,7)-SEDWQM(I,7)*FDB7)/       & 
                        DEP_BEN)/DAY_SEC + BENFLUX(I,7)
         BENFLUX(I,8) = (-DIFF_Z*(F(I,KB,8)*FD8-SEDWQM(I,8)*FDB8)/   &
                        DEP_BEN)/DAY_SEC + BENFLUX(I,8)
       END IF
     END DO
   END IF
!----------------------------------------------------------------
!                                                                
!  the following section solves the equation               
!  dti*(kh*f')' -f=-fb
!                                                                
!----------------------------------------------------------------

   DO K = 2, KBM1
     DO I = 1, M
#  if !defined (WET_DRY)
       IF(D(I) > 0.0_SP)THEN
#  else
       IF(ISWETN(I) == 1)THEN
#  endif
         FKH=KH(I,K)

         AF(I,K-1)=-DTI*(FKH+UMOLPR)/(DZ(I,K-1)*DZZ(I,K-1)*D(I)*D(I))
         CF(I,K)=-DTI*(FKH+UMOLPR)/(DZ(I,K)*DZZ(I,K-1)*D(I)*D(I))
       END IF
     END DO
   END DO

   WFSURF = 0.0_SP

!------------------------------------------------
!  Surface BCs; WFSURF
!----------------------------------------------- 

   DO N1=1,NB
     DO I = 1, M
#  if !defined (WET_DRY)
       IF (D(I) > 0.0_SP) THEN
#  else
       IF(ISWETN(I) == 1)THEN
#  endif
         VHF(I,1,N1) = AF(I,1) / (AF(I,1)-1.)
         VHPF(I,1,N1) = -DTI * WFSURF(I,N1) / (-DZ(I,1)*D(I)) - F(I,1,N1)
         VHPF(I,1,N1) = VHPF(I,1,N1) / (AF(I,1)-1.)
       END IF
     END DO
   END DO
       
   DO N1=1,NB
     DO K = 2, KBM2
       DO I = 1, M
#  if !defined (WET_DRY)
         IF(D(I) > 0.0_SP) THEN
#  else
         IF(ISWETN(I) == 1)THEN
#  endif
           VHPF(I,K,N1)=1./ (AF(I,K)+CF(I,K)*(1.-VHF(I,K-1,N1))-1.)
           VHF(I,K,N1) = AF(I,K) * VHPF(I,K,N1)
           VHPF(I,K,N1) = (CF(I,K)*VHPF(I,K-1,N1)-          &
                          DBLE(F(I,K,N1)))*VHPF(I,K,N1)
         END IF
       END DO
     END DO
   END DO

   DO N1=1,NB
     DO K = 1, KBM1 
       DO I = 1, M
#  if !defined (WET_DRY)
         If (D(I) > 0.0_SP)THEN
#  else
         IF(ISWETN(I) == 1)THEN
#  endif
           FF(I,K,N1) = F(I,K,N1)
         END IF
       END DO
     END DO
   END DO

   DO N1=1,NB
     DO I = 1, M
#  if !defined (WET_DRY)
       IF (D(I) > 0.0_SP .AND. ISONB(I) /= 2) THEN
#  else
       IF(ISWETN(I) == 1 .AND.ISONB(I) /= 2)THEN
#  endif
         FF(I,KBM1,N1) = (CF(I,KBM1)*VHPF(I,KBM2,N1)-FF(I,KBM1,N1)   &
                         -DTI*BENFLUX(I,N1)/(D(I)*DZ(I,KBM1)))/  &
                         (CF(I,KBM1)*(1.-VHF(I,KBM2,N1))-1.)
       END IF
     END DO
   END DO

   DO N1=1,NB
     DO K = 2, KBM1
       KI = KB - K
       DO I = 1, M
#  if !defined (WET_DRY)
         IF (D(I) > 0.0_SP .AND. ISONB(I) /= 2) THEN
#  else
         IF(ISWETN(I) == 1 .AND.ISONB(I) /= 2)THEN
#  endif
           FF(I,KI,N1) = (VHF(I,KI,N1)*FF(I,KI+1,N1)+VHPF(I,KI,N1))
         END IF
       END DO
     END DO
   END DO

   DO N1=1,NB
     DO I = 1, M
#  if !defined (WET_DRY)
       IF(D(I) > 0.0_SP)THEN
#  else
       IF(ISWETN(I)*ISWETNT(I) == 1 )then
#  endif
         DO K = 1, KBM1
           F(I,K,N1) = FF(I,K,N1)
         END DO
       END IF
     END DO
   END DO

!
!----------------- CALCULATE BOTTOM CONCENTRATION ----------------------
!
   IF (BENWQM_KEY) THEN
     DO N1 = 1, NB
       DO K = 1, KBM1
         DO I = 1, M
#  if !defined (WET_DRY)
           IF (D(I) > 0.0_SP) THEN
#  else
           IF(ISWETN(I)*ISWETNT(I) == 1 )then
#  endif
             F(I,KB,N1) = F(I,KBM1,N1)-DZZ(I,KBM1)*D(I)*      &
                          BENFLUX(I,N1)/(KH(I,KBM1)+UMOLPR)
           END IF
         END DO
       END DO
     END DO
   END IF

   RETURN
   END SUBROUTINE VDIF_WQM
!==============================================================================!

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

   SUBROUTINE EXCHANGE_WQM
!==============================================================================!
!     PERFORM DATA EXCHANGE FOR WATER QUALITY VARIABLES                        |
!==============================================================================!
#  if defined (MULTIPROCESSOR)
   USE MOD_PAR
#  endif      
   USE LIMS
   USE CONTROL
   IMPLICIT NONE
                                                                                                                         
#  if defined (MULTIPROCESSOR)
   IF(PAR .AND. WQM_ON)THEN
     CALL EXCHANGE(NC,MT,KB,MYID,NPROCS,WQM(:,:,1),WQM(:,:,2),WQM(:,:,3))
     CALL EXCHANGE(NC,MT,KB,MYID,NPROCS,WQM(:,:,4),WQM(:,:,5),WQM(:,:,6))
     CALL EXCHANGE(NC,MT,KB,MYID,NPROCS,WQM(:,:,7),WQM(:,:,8))
   END IF
#  endif
   RETURN
   END SUBROUTINE EXCHANGE_WQM
!==============================================================================!



!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

!==============================================================================!
   SUBROUTINE WQMCONST
!==============================================================================!
!   This subroutine calculates the constant parameters used in the water       !
!   quality model in the Satilla River, Georgia.			       !
!==============================================================================!

   USE ALL_VARS
   IMPLICIT NONE

   REAL(SP) :: S_K, T_K, WINDS, DEP, RK
   REAL(SP) :: U_W, V_W, T_W, K2_WIND, K2_HYDRA
   REAL(SP) :: XEMP1, XEMP2, SOLAR_T, ZDEP, CHL1, SKE, ALPHA_T, ALPHA_B
   INTEGER  :: I, K, II

!-------------- DO saturation concentration CS, mg O2/l ------------------
!  Dissolved oxygen saturation is determined as a function of temperature,
!  in degrees K, and salinity S (APHA, 1985).
!  APHA (American Public Health Association), 1985. Standard Methods for 
!  the Examination of water and wastewater, 15th Edition. APHA, Washington,
!  D. C.

   CS = 0.0_SP

   DO I = 1, M
     DO K = 1, KBM1
       IF (D(I) > 0.0_SP) THEN
         S_K = S1(I,K)
         T_K = T1(I,K) + 273.16_SP
         CS(I,K) = -139.34411_SP+(1.575701E5_SP)/T_K-(6.642308E7_SP)/T_K**2    &
                   +(1.243800E10_SP)/T_K**3-(8.621949E11_SP)/T_K**4            & 
                   -0.5535_SP*S_K*(0.031929_SP-19.428_SP/T_K+3867.3_SP/T_K**2)
         CS(I,K) = EXP(CS(I,K))
       END IF
     END DO
   END DO
 
!-------------- Reaeration rate K_reae at 20 degree, day^-1 -------------
!  Reaeration rate is maximum of reaeration induced by water velocity and
!  wind. For flow-induced reaeration, when depth less than 2 feet, Owens
!  formula is used. For depth deeper than 2 feet, higher flow uses 
!  Churchill formula, and slower flow uses O''Connor-Dobbins formula.
!  The reaeration rate in the salt marshes in very small compare with that
!  in the estuary. We cannot use following formula to calculate reaeration
!  rate because it is used at the open estuary. The reasonable value of
!  reaeration rate in the salt marshes is one-third to half of that in
!  the estuary. We set it as constant in the salt marsh and its value is
!  0.1 day^-1.

   K_REAE = 0.0_SP
   DO I = 1, M
     DO K = 1, KBM1
       IF(D(I) > 0.0_SP .AND. K == 1) THEN
         WINDS = 1.0
         DEP = D(I)
         U_W = 0.0
         V_W = 0.0
         DO II = 1, NTVE(I)
           U_W = U_W + U(NBVE(I,II),K)
           V_W = V_W + V(NBVE(I,II),K)
         END DO
         U_W = U_W/NTVE(I)
         V_W = V_W/NTVE(I)
         T_W = T1(I,K)         ! JQI In Zheng''s code T_W=20.0
         CALL KAHYDRA(K2_HYDRA,DEP,U_W,V_W,T_W)
         CALL KAWIND(WINDS,T_W,TA,RK,DEP)
         K2_WIND = RK
         IF(K2_WIND > K2_HYDRA) THEN
           K_REAE(I,K) = K2_WIND
         ELSE
           K_REAE(I,K) = K2_HYDRA
         END IF
       END IF
     END DO
   END DO
! 
!-------------- Compute ammonia preference PNH3G --------------------
!
   PNH3G = 0.0_SP

   DO I = 1, M
     DO K = 1, KBM1
       IF (D(I) > 0.0_SP) THEN
         IF(WQM(I,K,4) > 1.0E-5_SP) THEN
           PNH3G(I,K) = WQM(I,K,4)*WQM(I,K,5)/((WQM(I,K,4)+                  &
                        KMN*1.0E-3_SP)*(WQM(I,K,5)+KMN*1.0E-3_SP))+          &
                        WQM(I,K,4)*KMN*1.0E-3_SP/((WQM(I,K,4)+WQM(I,K,5)+    &
                        1.E-30_SP)*(WQM(I,K,5)+KMN*1.0E-3_SP))
         END IF
       END IF
     END DO
   END DO
! 
!  Compute growth rate reduction due to nutrient limitation factor RNUTR
!
   RNUTR = 0.0_SP
   DO I = 1, M
     DO K = 1, KBM1
       IF (D(I) > 0.0_SP) THEN
         XEMP1 = (WQM(I,K,4)+WQM(I,K,5))/(WQM(I,K,4)+      &
                 WQM(I,K,5)+KMN*1.0E-3_SP)
         XEMP2 = WQM(I,K,7)/(WQM(I,K,7)+KMP*1.0E-3_SP)
         RNUTR(I,K) = MIN(XEMP1,XEMP2)
       END IF
     END DO
   END DO 
! 
! Compute growth rate reduction due to light conditions using  
! Dick Smith''s formulation
!
   RLIGHT = 0.0_SP
   DO I = 1, M
     DO K = 1, KBM1
       IF (D(I) > 0.0_SP) THEN
         SOLAR_T = 0.0_SP
         ZDEP = 0.5_SP * (Z(I,K)+Z(I,K+1))
         DEP = D(I)
         IF(TIME_R > TIME_U .AND. TIME_R < TIME_D) THEN
           SOLAR_T = SOLAR_A*24.0_SP/(TIME_D-TIME_U)*3.1415926_SP/2.0_SP*   &
                     SIN(3.1415926_SP*(TIME_R-TIME_U)/(TIME_D-TIME_U))
         END IF
         CHL1 = WQM(I,K,3)*80.0_SP/1000.0_SP
         SKE = 0.0088_SP*CHL1*1000.0_SP + 0.054_SP*(1000.0_SP*CHL1)**0.6667_SP

!JQI In ECOM:           If(I.LE.23) Then
!JQI In ECOM:           Ske = Ske + 10
!JQI In ECOM:           Else If(I.GE.123) Then
!JQI In ECOM:           Ske = Ske + 1.5
!JQI In ECOM:           Else
!JQI  In ECOM:          Ske = Ske + 10 - 8.5 * (I-23) / 100.0
!JQI In ECOM:           End If

         IF(VX(I) <= 202000-VXMIN) THEN
           SKE = SKE + 10.0_SP
         ELSE IF(VX(I) >= 223300-VXMIN) THEN
           SKE = SKE + 1.5_SP
         ELSE
           SKE = SKE + 10.0_SP - 8.5_SP * (VX(I)-(202000-VXMIN)) / 21300.0_SP
         END IF

         ALPHA_T = -SOLAR_T/SOLAR_S
         ALPHA_B = ALPHA_T * EXP(SKE*DEP*ZDEP)
         IF(SKE == 0.0_SP) THEN
           RLIGHT(I,K) = 0.0
         ELSE
           RLIGHT(I,K) = -2.718_SP/(SKE*DEP*ZDEP)*(EXP(ALPHA_B)-    &
                         EXP(ALPHA_T))
         END IF
       END IF 
     END DO
   END DO
! 
!  Compute phytoplankton growth rate GPP
!
   GPP = 0.0_SP
   DO I = 1, M
     DO K = 1, KBM1
       IF(D(I) > 0.0_SP) THEN
! JQI In Zheng''s code:         T1(I,K) = 20.0
         GPP(I,K) = K_GROW*TEMP_GROW**(T1(I,K)-20)*    &
                    RLIGHT(I,K)*RNUTR(I,K)
       END IF
     END DO
   END DO
! 
!  Compute phytoplankton loss rate DPP
!
   DPP = 0.0_SP
   DO I = 1, M
     DO K = 1, KBM1
       IF(D(I) > 0.0_SP) THEN
! JQI In Zheng''s code:           T1(I,K) = 20.0
         DPP(I,K) = K_RESP*TEMP_RESP**(T1(I,K)-20)+     &
                    K_MORT*TEMP_MORT**(T1(I,K)-20)
       END IF
     END DO
   END DO
! 
!  Compute bacterial respiration rate. Its value from 0.1 in
!  the inner shelf to 0.3 uM/h in the end of the river.
!
   K_RESPP = 0.0_SP 
   DO I = 1, M
     IF(D(I) > 0.0_SP) THEN
       IF(H(I) <= 1.0_SP) THEN
         K_RESPP(I) = 0.4_SP
       ELSE
         K_RESPP(I) = 0.1_SP
       END IF
     END IF
   END DO
! 
!  Compute sediment oxygen demand rate. Its value from 0.1 in
!  the inner shelf to 1.2 in the end of the river. At the salt
!  marshes, its value is specified as 1.2 g/(m^2.d)
!
   SODD = 0.0_SP
   DO I = 1, M
     DO K = 1, KBM1
       IF(D(I) > 0.0_SP .AND. K == KBM1) THEN
         IF(H(I) <= 1.0_SP) THEN
           SODD(I,K) = 1.0_SP
!JQI In ECOM:           Else If(I.LE.90) Then
!JQI In ECOM:            SODD(I,J,K) = 0.4
!JQI In ECOM:           Else If(I.GE.110) Then
!JQI In ECOM:            SODD(I,J,K) = 0.1
!JQI In ECOM:           Else If(I.GT.90.and.I.LT.110) Then
!JQI In ECOM:            SODD(I,J,K) = 0.4 - 0.3*(I-90)/20.0
         ELSE IF(VX(I) <= 216000-VXMIN) THEN
           SODD(I,K) = 0.4_SP
         ELSE IF(VX(I) >= 220000-VXMIN) THEN
           SODD(I,K) = 0.1_SP
         ELSE IF(VX(I) > 216000-VXMIN .AND. VX(I) < 220000-VXMIN) THEN
           SODD(I,K) = 0.4_SP - 0.3_SP*(VX(I)-(216000-VXMIN))/4000.0_SP
         END IF
       END IF
     END DO
   END DO
! 
!  Compute the fraction of dead and respired phytoplankton recycled
!  to the organic pool: 0 in the inner shelf and 1 at the upstream
!  end of the river.
!
   F_ONN = 0.0_SP
   F_OPP = 0.0_SP 
   DO I = 1, M
     IF(D(I) > 0.0_SP) THEN
!JQI In ECOM:          F_ONN(I) = (I-10.0)/100.0
!JQI In ECOM:          F_OPP(I) = (I-10.0)/100.0
       F_ONN(I) = (VX(I)-(196500-VXMIN))/23500.0_SP
       F_OPP(I) = (VX(I)-(196500-VXMIN))/23500.0_SP
     END IF
     IF(F_ONN(I) >= 1.0_SP) F_ONN(I) = 1.0_SP
     IF(F_ONN(I) <= 0.0_SP) F_ONN(I) = 0.0_SP
     IF(F_OPP(I) >= 1.0_SP) F_OPP(I) = 1.0_SP
     IF(F_OPP(I) <= 0.0_SP) F_OPP(I) = 0.0_SP
   END DO
! 
!  Compute nitrification rate: o.35 when salinity less than 5ppt, and
!  0.05 when salinity larger than 30 ppt. Between them, it is linear
!  change.
!
   K_NITRR = 0.0_SP 
   DO I = 1, M
     DO K = 1, KBM1
       IF(D(I) > 0.0_SP) THEN
         IF(S1(I,K) <= 5.0_SP) THEN
           K_NITRR(I,K) = 0.35_SP
         ELSE IF(S1(I,K) >= 15.0_SP) THEN
           K_NITRR(I,K) = 0.1_SP
         ELSE
           K_NITRR(I,K) = 0.35_SP-0.25_SP*(S1(I,K)-5.0_SP)/10.0_SP
         END IF
       END IF
     END DO
   END DO
! 
!   Compute the nutrients released from sediment: low near the river 
!   mouth and inner shelf and high in the upstream
!
   RSED1 = 0.0_SP
   RSED2 = 0.0_SP
   RSED3 = 0.0_SP 
   DO I = 1, M
!JQI In ECOM:          If (D(I).GT.0.0.and.I.GT.110) Then
     IF(D(I) > 0.0_SP .AND. VX(I) > 220000-VXMIN) THEN
       RSED1(I) = 0.0_SP
       RSED2(I) = 0.0_SP
       RSED3(I) = 0.0_SP
!JQI In ECOM:          Else If(D(I).GT.0.0.and.I.LT.60) Then
     ELSE IF(D(I) > 0.0_SP .AND. VX(I) < 209500-VXMIN) THEN
       RSED1(I) = RSED_NH4
       RSED2(I) = RSED_NO3
       RSED3(I) = RSED_OP4
     ELSE IF(D(I) > 0.0_SP) THEN
!JQI In ECOM:           Rsed1(I) = Rsed_NH4 * (110.0 - I) / 50.0
!JQI In ECOM:           Rsed2(I) = Rsed_NO3 * (110.0 - I) / 50.0
!JQI In ECOM:           Rsed3(I) = Rsed_OP4 * (110.0 - I) / 50.0
       RSED1(I) = RSED_NH4 * (220000 - VX(I)) / 10500.0_SP
       RSED2(I) = RSED_NO3 * (220000 - VX(I)) / 10500.0_SP
       RSED3(I) = RSED_OP4 * (220000 - VX(I)) / 10500.0_SP
     END IF
   END DO
        
   RETURN
   END SUBROUTINE WQMCONST
!=============================================================================!         


!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

!=============================================================================!         
   SUBROUTINE KAHYDRA(K2_HYDRA,DEP,U_TEMP,V_TEMP,T_TEMP)
!=============================================================================!         
! Calculate Oxygen Reaeration induced by flow                                 ! 
!=============================================================================!         
 
   USE MOD_PREC
   IMPLICIT NONE

   REAL(SP), INTENT(OUT) :: K2_HYDRA
   REAL(SP), INTENT(IN)  :: U_TEMP,V_TEMP,T_TEMP
   REAL(SP), INTENT(IN)  :: DEP  
   REAL(SP)              :: AVDEPE,AVVELE
   REAL(SP)              :: REAK,EXPREV,EXPRED
   REAL(SP)              :: TRANDP,DIF,RK20 

!
! Calculate Oxygen Reaeration induced by flow
!
   AVDEPE = DEP
   AVVELE = SQRT(U_TEMP**2+V_TEMP**2)
        
! Calculate reaeration coefficient as a power function of average
! hydraulic depth and velocity; determine exponents to depth and
! velocity terms and assign value to REAK

   IF(AVDEPE <= 0.61_SP) THEN
! Use Owen9s formulation for reaeration
     REAK   = 5.349_SP
     EXPREV = 0.67_SP
     EXPRED = -1.85_SP
   ELSE
! Calculate transition depth; transition depth determines which 
! method of calculation is used given the current velocity.
     IF(AVVELE < 0.518_SP) THEN
       TRANDP = 0.0_SP
     ELSE
       TRANDP = 4.411_SP*(AVVELE**2.9135_SP)
     END IF

     DIF = AVDEPE - TRANDP
     IF(DIF <= 0.0_SP) THEN
! Use Churchill9s formulation for reaeration
       REAK   = 5.049_SP
       EXPREV = 0.969_SP
       EXPRED = -1.673_SP
     ELSE
! Use O9Connor-Dobbins formulation for reaeration
       REAK   = 3.93_SP
       EXPREV = 0.5_SP
       EXPRED = -1.5_SP
     END IF
   END IF

! Calculate reaeration coefficient induced by flow
   RK20 = REAK*(AVVELE**EXPREV)*(MAX(0.5_SP,AVDEPE)**EXPRED)
   IF(RK20 > 24.0_SP) RK20 = 24.0_SP
   K2_HYDRA = RK20*1.028_SP**(T_TEMP-20.0_SP)

   RETURN
   END SUBROUTINE KAHYDRA

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

!=============================================================================!
!  Calculate Oxygen Reaeration induced by wind				      !
!=============================================================================!
   SUBROUTINE KAWIND(WINDS,TW,TA,RK,DEP)
!=============================================================================!
!									      !
!  Given:								      !
!    Winds = Wind speed (m/s)						      !
!    Ta    = temperature of the air (Degrees C)				      !
!    Tw    = Water temperature (Degrees C)				      !
!  Reference:								      !
!    Journal of Environmental Engineering, Vol. 109, No. 3,		      !
!    pp. 731-752, Author: D. J. O'Connor, Title: 99Wind effects		      !
!    on Gas-Liquid Transfer Coefficient99				      !
!									      !
!    VERSION(01/05/2004)						      !
!=============================================================================!
        
!=============================================================================!
!  Parameters used in the model include:
!
!    Transitional Shear Velocity - UT (cm/sec)
!    Critical Hsear Velocity - UC (cm/sec)
!    Von Karmen9 s constant (VKA)
!    Equilibrium Roughness - Ze (cm)
!    1/LAM is a Reynold9 s Number
!    GAM is a nondimensional coefficient dependent on water body size
!    LAM, GAM, UT, UC, and Ze are dependent on water body size
!
!        UT     UC    Ze    LAM    GAM
!       10.0  11.0  0.35    3.0    5.0           Large Scale
!       10.0  11.0  0.25    3.0    6.5           Intermediate
!        9.0  22.0  0.25   10.0   10.0           Small Scale
!
!       In the Satilla River, it is thought as small scale.
!=============================================================================!
   USE MOD_PREC
   IMPLICIT NONE

   REAL(SP), INTENT(OUT):: RK
   REAL(SP), INTENT(IN) :: TW, TA
   REAL(SP), INTENT(IN) :: DEP
   REAL(SP)             :: WINDS
   REAL(SP)             :: UT_0,UC,ZE,LAM,GAM
   REAL(SP)             :: DIFF,VW,VA_0,PA,PW
   REAL(SP)             :: VKA,VKA3,WH
   REAL(SP)             :: SRCD,SRCD2,EF,F1,F2,FP1,FP2,FP3,FP4,ERR
   REAL(SP)             :: CD,US,Z0,RK1,RK2,RK3,GAMU
   INTEGER              :: N_0
        
   UT_0 =  9.0_SP
   UC   = 22.0_SP
   ZE   = 0.25_SP
   LAM  = 10.0_SP
   GAM  = 10.0_SP
!
! Calculate diffusivity of oxygen in water (DIFF) (cm^2/sec), 
! viscosity of water (VW) (cm^2/sec), viscosity of air (VA) (cm^2/sec),
! density of water (PW) (g/cm^3), and density of air (PA) (g/cm^3)
!
   DIFF  = 4.58E-07_SP * TW + 1.2E-05_SP
   VW    = 1.64E-02_SP - 2.4514E-04_SP * TW
   VA_0  = 1.33E-01_SP + 9E-04_SP * TA
   PA    = 1.29E-03_SP - 4E-06_SP * TA
   PW    = 1.0_SP
   WINDS = WINDS * 100.0_SP
   RK    = 1.0_SP

!
! Use Newton Raphson method to calculate the square root of the drag
! coefficient
!
   N_0  = 0
   VKA  = 0.4_SP
   VKA3 = VKA**0.3333_SP
   WH   = 1000.0_SP
!
! Make initial guess for square root of the Drag coefficient
!
   SRCD = 0.04

1000 CONTINUE
   N_0  = N_0 + 1
!
! Calculate value of function (F2) and derivative of function (FF or FP4)
!
   EF  = EXP(-SRCD*WINDS/UT_0)
   F1  = LOG((WH/ZE) + (WH*LAM/VA_0)*SRCD*WINDS*EF)
   F2  = F1 - VKA/SRCD
   FP1 = 1.0_SP/((WH/ZE) + (WH*LAM/VA_0)*SRCD*WINDS*EF)
   FP2 = ((WH*LAM)/(VA_0*UT_0))*SRCD*WINDS**2*EF
   FP3 = (WH*LAM/VA_0)*WINDS*EF
   FP4 = FP1*(FP2 + FP3) + (VKA/(SRCD**2))
!
! Calculate a new guess for square root of Drag coefficient and compare
! to previous guess and loop back through N-R with new guess if 
! appropriate
!
   SRCD2 = SRCD - F2/FP4
   ERR   = ABS(SRCD - SRCD2)
   IF(ERR > 0.005_SP .AND. N_0 < 8) THEN
     SRCD = SRCD2
     GOTO 1000
   END IF
        
   IF(ERR > 0.005_SP .AND. N_0 >= 8) THEN 
     WRITE(6,'(5X,"SOLUTION DID NOT CONVERGE")')
     CALL PSTOP
   ELSE
     CD    = SRCD**2
     US    = SRCD * WINDS
     Z0    = 1.0_SP/((1.0_SP/ZE) + LAM*US*EXP(-US/UT_0)/VA_0)
     WINDS = WINDS / 100.0_SP

     IF(WINDS < 6.0_SP) THEN
       RK1  = (DIFF/VW)**0.666667_SP * SRCD*SQRT(PA/PW)
       RK   = RK1 * VKA3 * WINDS/GAM
       RK   = RK*3600.0_SP *24.0_SP
     ELSE IF(WINDS >= 6.0_SP .AND. WINDS <= 20.0_SP) THEN
       GAMU = GAM*US*EXP(-US/UC + 1.0_SP)/UC
       RK1  = (DIFF/VW)**.666667_SP * VKA3 * SQRT(PA/PW)*US/GAMU
       RK2  = SQRT(DIFF*US*PA*VA_0/(VKA*Z0*PW*VW))
       RK3  = (1.0_SP/RK1) + (1.0_SP/RK2)
       RK   = 1.0_SP/RK3
       RK   = RK *3600.0_SP * 24.0_SP/100.0_SP
     ELSE IF(WINDS > 20.0_SP) THEN
       RK   = SQRT(DIFF*PA*VA_0*US/(VKA*ZE*PW*VW))
       RK   = RK*3600.0_SP * 24.0_SP/100.0_SP
     END IF
   END IF

   RK = RK / DEP

   RETURN
   END SUBROUTINE KAWIND
!=============================================================================!
#  endif
   END MODULE MOD_WQM
