#!/bin/bash

Check_Repeating_Time=3; # in seconds
Max_CPU_Usage='25.0'; #%
Max_RAM_Usage='2.0'; #%
Log_Path='/var/log/auto_killer_log'; # path to file when killing logs will be writed

while [ 1 ]; do

    ps -aux | 
    awk '{
        Username = $1;
        Proc_Name = $11;
        CPU_Usage = $3;
        RAM_Usage = $4;
        PID = $2;
        TTY = $7;

        if((CPU_Usage >= '$Max_CPU_Usage' || RAM_Usage >= '$Max_RAM_Usage' ) &&  !($1 == "USER" || $1 == "root" || $1 == "daemon" || $1 == "mysql" || $1 == "avahi" || $1 == "polkitd"))
        {
            Func_Num_of_Ocur = "cat ./auto_killer_data | grep "PID" | wc -l";
            Func_Num_of_Ocur |getline Str_Num_Of_Ocur;              

            if(Str_Num_Of_Ocur == "0")
            {
                system ("echo \"\" >> /dev/" TTY);
                system ("echo \"Process "Proc_Name" used to much of resources. It will be killed in '$Check_Repeating_Time' seconds if it wont stop!\" >> /dev/" TTY );
                system ("echo \"\" >> /dev/" TTY);
                system ("echo "PID" >> ./auto_killer_data.new");
            }
            else
            {
                system ("echo \"\" >> /dev/" TTY);
                system ("echo \"Process "Proc_Name" was killed because it used to much of system resources!\" >> /dev/" TTY );
                system ("echo \"\" >> /dev/" TTY);
                system ("kill -9 " PID);
                Data = "date";
                Data |getline Str_Data;
                system ("echo \""Str_Data"  "Username"  "Proc_Name" "TTY"\" >> '$Log_Path'");
            }
        }
    }';

    if [ -e ./auto_killer_data.new ]; then
        mv ./auto_killer_data.new ./auto_killer_data
    else    
        echo '' > ./auto_killer_data
    fi

    #We wait fo a while and repeate process
    sleep $Check_Repeating_Time\s;
done;

