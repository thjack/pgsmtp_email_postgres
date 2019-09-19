create schema pgsmtp AUTHORIZATION postgres;


CREATE TABLE pgsmtp.user_smtp_data
 (smtp_user character varying, smtp_server character varying, smtp_port integer, smtp_pass character varying );

CREATE OR REPLACE FUNCTION pgsmtp.pg_smtp_mail(
    sender character varying,
    receiver character varying,
    cc text[],
	cco text[],
    topic character varying,
    content text)
  RETURNS text AS
$BODY$

import os
import sys
import smtplib
from email import encoders
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart

COMMASPACE = ', '

# find data about sender
query = "SELECT smtp_server,smtp_port,smtp_pass FROM pgsmtp.user_smtp_data where smtp_user='" +sender + "' LIMIT 1"
result = plpy.execute(query)
if result:
    #sender = 'YOUR GMAIL ADDRESS'
    #gmail_password = 'YOUR GMAIL PASSWORD'
    #recipients = ['EMAIL ADDRESSES HERE SEPARATED BY COMMAS']
    
    # Create the enclosing (outer) message
    outer = MIMEMultipart()
    #outer['Subject'] = 'EMAIL SUBJECT'
    outer['Subject'] = topic
    #outer['To'] = COMMASPACE.join(recipients)
    outer['To'] = receiver
    outer['cc'] = COMMASPACE.join(cc)
    outer['cco'] = COMMASPACE.join(cco)
    outer['From'] = sender
    outer.preamble = 'You will not see this in a MIME-aware mail reader.\n'
    # List of attachments
    attachments = ['FULL PATH TO ATTACHMENTS HERE']

    #### Add the attachments to the message
    #for file in attachments:
    #    try:
    #        with open(file, 'rb') as fp:
    #            msg = MIMEBase('application', "octet-stream")
    #            msg.set_payload(fp.read())
    #        encoders.encode_base64(msg)
    #        msg.add_header('Content-Disposition', 'attachment', filename=os.path.basename(file))
    #        outer.attach(msg)
    #    except:
    #        print("Unable to open one of the attachments. Error: ", sys.exc_info()[0])
    #        raise
    #outer.attach(content)
    #outer.attach(MIMEText(str(content)))
    outer.attach(MIMEText(content))
    composed = outer.as_string() 

    # Send the email
    try:
        with smtplib.SMTP(result[0]['smtp_server'], result[0]['smtp_port']) as s:
            #s.ehlo()
            s.ehlo_or_helo_if_needed()
            s.starttls()
            #s.ehlo()
            s.ehlo_or_helo_if_needed()
            s.login(sender, result[0]['smtp_pass'])
            #s.sendmail(sender, recipients, composed)
            rcpt = [receiver] + cc + cco
            #s.sendmail(sender, receiver, composed)
            s.sendmail(sender, rcpt, composed)
            s.close()
        return "Email sent!"
    except:
        return "Unable to send the email. Error: ", sys.exc_info()[0]
		
$BODY$
LANGUAGE plpython3u VOLATILE;


CREATE OR REPLACE FUNCTION pgsmtp.pg_smtp_mail_attach(
    sender character varying,
    receiver character varying,
    cc text[],
	cco text[],
    topic character varying,
    content text,
	attachments text[])
  RETURNS text AS
$BODY$

import os
import sys
import smtplib
from email import encoders
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart

COMMASPACE = ', '

# find data about sender
query = "SELECT smtp_server,smtp_port,smtp_pass FROM pgsmtp.user_smtp_data where smtp_user='" +sender + "' LIMIT 1"
result = plpy.execute(query)
if result:
    #sender = 'YOUR GMAIL ADDRESS'
    #gmail_password = 'YOUR GMAIL PASSWORD'
    #recipients = ['EMAIL ADDRESSES HERE SEPARATED BY COMMAS']
    
    # Create the enclosing (outer) message
    outer = MIMEMultipart()
    #outer['Subject'] = 'EMAIL SUBJECT'
    outer['Subject'] = topic
    #outer['To'] = COMMASPACE.join(recipients)
    outer['To'] = receiver
    outer['cc'] = COMMASPACE.join(cc)
    outer['cco'] = COMMASPACE.join(cco)
    outer['From'] = sender
    outer.preamble = 'You will not see this in a MIME-aware mail reader.\n'
    # List of attachments
    # attachments = ['FULL PATH TO ATTACHMENTS HERE']

    outer.attach(MIMEText(content))    
	

    ### Add the attachments to the message
    for file in attachments:
        try:
            with open(file, 'rb') as fp:
                msg = MIMEBase('application', "octet-stream")
                msg.set_payload(fp.read())
            encoders.encode_base64(msg)
            msg.add_header('Content-Disposition', 'attachment', filename=os.path.basename(file))
            outer.attach(msg)
        except:
            return "Unable to open one of the attachments. Error: ", sys.exc_info()[0]
            raise

    composed = outer.as_string() 

    # Send the email
    try:
        with smtplib.SMTP(result[0]['smtp_server'], result[0]['smtp_port']) as s:
            #s.ehlo()
            s.ehlo_or_helo_if_needed()
            s.starttls()
            #s.ehlo()
            s.ehlo_or_helo_if_needed()
            s.login(sender, result[0]['smtp_pass'])
            #s.sendmail(sender, recipients, composed)
            rcpt = [receiver] + cc + cco
            #s.sendmail(sender, receiver, composed)
            s.sendmail(sender, rcpt, composed)
            s.close()
        return "Email sent!"
    except:
        return "Unable to send the email. Error: ", sys.exc_info()[0]
		
$BODY$
LANGUAGE plpython3u VOLATILE;
