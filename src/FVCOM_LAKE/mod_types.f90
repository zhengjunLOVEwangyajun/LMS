MODULE MOD_TYPES
USE MOD_PREC
IMPLICIT NONE
TYPE MAP
   INTEGER  NSIZE
   INTEGER, POINTER,  DIMENSION(:) :: LOC_2_GL
END TYPE MAP

TYPE COMM
!----------------------------------------------------------
! SND: TRUE IF YOU ARE TO SEND TO PROCESSOR               |
! RCV: TRUE IF YOU ARE TO RECEIVE FROM PROCESSOR          |
! NSND: NUMBER OF DATA TO SEND TO PROCESSOR               |
! NRCV: NUMBER OF DATA TO RECEIVE FROM PROCESSOR          |
! SNDP: ARRAY POINTING TO LOCATIONS TO SEND TO PROCESSOR  | 
! RCVP: ARRAY POINTING TO LOCATIONS RECEIVED FROM PROCESS |
! RCPT: POINTER TO LOCATION IN RECEIVE BUFFER             |
!----------------------------------------------------------

!  LOGICAL :: SND,RCV
  INTEGER  NSND,NRCV,RCPT
  INTEGER, POINTER,  DIMENSION(:) :: SNDP,RCVP
  REAL(SP), POINTER,   DIMENSION(:) :: MLTP
END TYPE COMM

TYPE BC
   INTEGER NTIMES
   REAL(SP), POINTER,  DIMENSION(:) :: TIMES
   CHARACTER(LEN=80) :: LABEL
END TYPE BC

END MODULE MOD_TYPES

