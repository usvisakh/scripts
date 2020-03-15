##########script by visakh############:wq!





#!/bin/bash

email_limit=50; #per hour
to_email="info@zagirova.com";
from_email="noreply@zagirova.design";
skip_accounts="gruporamos"


/usr/sbin/exigrep  "$(date --date="1 hours ago" +%Y-%m-%d\ %H)"  /var/log/exim_mainlog \
| grep "<="| grep -v "<>"|cut -d "=" -f2 |cut -d " " -f2| sort | uniq -c|sort -n| awk -v limit=$email_limit '$1 > limit'\
| while read line ; do 
    found="";
    match="";
    domain="$(echo $line |cut -d "@" -f2)"; 
    domain2="$(grep -w "$domain" /etc/localdomains|head -1)";
    domain3="$(grep -w "$domain" /etc/remotedomains|head -1)";
    if [ "$domain" = `hostname` ]; then user="$(echo $line |cut -d "@" -f1|cut -d" " -f2)";
        acc=$user;
        for i in $skip_accounts;do  
            found=$(echo $i|grep -w  $acc); if [ $found ];then match=1; else match=0; fi;
        done;
		if [ $match = 0 ]; then 
			/usr/sbin/whmapi1 suspend_outgoing_email user=$acc
			user="$user@`hostname`";
		fi;
    elif [ "$domain2" = "$domain" ]; then user="$(echo $line |cut -d " " -f2)"; 
        acc=$(/scripts/whoowns $(echo $user|cut -d"@" -f2));
        for i in $skip_accounts;do  
            found=$(echo $i|grep -w  $acc); if [ $found ];then match=1; else match=0; fi; 
        done;
		if [ $match = 0 ]; then 
			echo "";
			/usr/bin/uapi --user=$acc Email suspend_outgoing email=$user;
		fi;
    elif [ "$domain3" = "$domain" ]; then user="$(echo $line |cut -d " " -f2)";
        acc=$(/scripts/whoowns $(echo $user|cut -d"@" -f2));
        for i in $skip_accounts;do  
            found=$(echo $i|grep -w  $acc); if [ $found ];then match=1; else match=0; fi;
        done;
		if [ $match = 0 ]; then 
			echo "";
			/usr/bin/uapi --user=$acc Email suspend_outgoing email=$user;
		fi;
    fi;
	echo -e "Email Account : $usercPanel \nAccount : $acc\nNumber of Emails send out : $countHourly\nLimit : $email_limit";
	
	if [ $match = 0 ]; then 
        count="$(echo $line |cut -d " " -f1)"; 
 wp_mail="From: $from_email\nTo: $to_email\nSubject: Email Account Suspension\nMime-Version: 1.0\nContent-Type: text/html\n\n<p style='text-align: justify;'><p>Hello,</p>
        <p>The server has been suspeded following email user due to excessive sending of emails from the server.</p><p>*********************</p>
        <p><span style='color: #ff0000;'>Email Account : $user</span></p><p><span style='color: #ff0000;'>cPanel Account : $acc</span></p><p><span style='color: #ff0000;'>
        Number of Emails send out : $count</span></p><p><span style='color: #ff0000;'>Hourly Limit : $email_limit</span></p><p><span style='color: #000000;'>*********************</span>
        </p><p>if the suspeded user is an email account then you can unsusped it from cpanel account email section.</p><p>&nbsp;</p><p>cPanel <span style='box-sizing: border-box;'>&raquo; 
        Email&nbsp;</span> <span style='box-sizing: border-box;'>&raquo; Email accounts &raquo; manage and unsusped the particular email account.<br />
        </span></p><p><span style='box-sizing: border-box;'>see the following screen to see how to unsuspend a blocked&nbsp; suspeded email.</span></p>
        <p><a href='https://i.imgur.com/UatzKbA.gif' target='_blank'><span style='box-sizing: border-box;'><img src='https://i.imgur.com/UatzKbA.gif' width='444' height='271' /></span></a></p><p>
        &nbsp;</p><p>If the suspended account is&nbsp; default email account (with cpanel username), then it cannot be unsuspended from cpanel interface so&nbsp; 
        please contact support for unsuspension.</p><p>&nbsp;</p><p>Thanks :)</p>
        ";
        echo -e $wp_mail | /usr/lib/sendmail -t 
    fi;
    
done
