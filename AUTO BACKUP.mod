MODULE MainModule
    !-----------------------------------------------
    ! Program Details 
    ! # TASK: BACKUP
    ! # SETUP: ABB 6700-200
    ! # CREATED: 30/06/2020
    ! # INITIAL AUTHOR: me1br - Ben Rae
    ! # DESCRIPTION: 
    !    This program is intended to automatically create backup files of the controller configuration and RAPID programs, at a set time every day.
    !    It is run through a seperate task, 'BACKUP', which is a non-motion, semi-static Task. This means that it automatically runs all the time, 
    !       in the background, and isn't stopped by the safety circuits being tripped (as they normally are over night as a precaution).
    !    This means that to make any edits, the BACKUP task must be changed to a Normal type in the Controller Configuation screen.
    !    Please list any edits or modifications to this program below.
    !-----------------------------------------------
    ! Modifications
    ! # 30/06/2020: Program created and initially tested
    !
    !-----------------------------------------------
	
    VAR string time;
    VAR string date;
    VAR string hour;
    VAR string min;
    
    VAR bool backedupyet := FALSE; 
    ! This boolean variable tracks whether a backup has been taken for a given time, to prevent the program making multiple, redundant backups.
    
    PERS string BACKUPHOUR := "06";
    ! This string represents the hour at which the backup will be taken, in 24 hour time. ie. 10pm = "22".
    ! PERS means that it is persistent, ie. accessible between different tasks. I'm hoping this means that we can somehow change it via an interface on the pendant.
    
    PROC main()
                
        time := CTime(); ! Returns the time in format hh:mm:ss
        date := CDate(); ! Returns the date in format yyyy:mm:dd
        
        ! Get the characters which represent the hour and minutes by taking substrings of the CTIME() result. 
        ! ie. hour = "22", min = "35"
        hour := StrPart(time,1,2);
        min := StrPart(time,4,2);
        
        ! If the hour matches the backup hour set above, and the minutes equal "00" (ie. on the hour)
        IF hour = BACKUPHOUR AND min = "00" AND backedupyet = FALSE THEN            
            
            PulseDO doBackup; ! Pulse the doBackup signal, which uses a cross-connection to simulate an input on diBackup (A system input which triggers a backup)            
            backedupyet := TRUE; ! Set the boolean tracker to TRUE
            
        ENDIF
            
        ! Five minutes later, reset the boolean tracker to ensure that we are ready for the following day's backup
        IF hour = BACKUPHOUR AND min = "05" AND backedupyet = TRUE THEN
            backedupyet := FALSE;            
        ENDIF
        
        WaitTime(45); 
        ! Wait for 45 seconds every iteration. I don't know if this actually saves any processing power, but it feels neater than running this task repeatedly! 
        ! Setting the time to something above 30 seconds should ensure that no multiple, redundant backups are taken as the task can only execute once in a given
        !  minute. However, I implemented the tracker boolean variable as a backup, and because it could be useful later on.
        
    ENDPROC
 
ENDMODULE