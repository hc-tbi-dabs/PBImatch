
Context: Our various program clients make requests to acquire PowerBI PRO licenses via our portal on Sharepoint.  When a request is made using the request form, their name gets added to a Sharepoint list, and the request proceeds through a Power Automate workflow.  In this workflow, the request gets passed to a designated approver (depending on the native Program of the requestor). If approved, the request is sent to the BI Operations team at the Digital Transformation Branch (DTB) and they will grant the license. 
In theory, any user in ROEB with a Power BI PRO license should appear on our Sharepoint list (since it is the de facto point-of-entry). However, sometimes there are incongruencies.  It is suggested that the Sharepoint list be reviewed against DTB’s list (this is considered the ‘official’ list) on a regular basis.  

Here are the steps to do so:

a.	Send an email to bioperations-operationsbi@hc-sc.gc.ca requesting an extract of the latest PowerBI User List for all workspaces in ROEB (they will send an Excel file)
b.	Open the file in Excel and click File > Save As > azure.csv (make sure to convert the file type to ‘CSV UTF-8’ [.csv]). 
c.	Navigate to Site Contents on the POD Sharepoint site and locate the Power BI Service Workspace Access List
d.	Switch to the ‘for_extract’ View
e.	In the top bar, click ‘Export > Export to CSV
f.	Locate the downloaded file in your File Explorer and rename it to sp.csv
g.	Ensure that both azure.csv and sp.csv are in the same directory location (eg. Downloads)
h.	Download the PBImatch_.R program from the DABS GitHub repository.  You will need to have R and RStudio installed on your device. Open the program in RStudio
i.	In the first line of code, change the working directory to the Directory location of the two CSV files.  (eg. C:/Users/YOURUSERNAME/Downloads)
j.	Select all (Ctrl-A), then click ‘Run’ 
k.	Navigate to the command line and type:  PBImatch(azure = azure, sp = sp, report = T)
l.	If successful, you should get the output: ‘Report exported to the directory (txt).’  Navigate to the working directory (if you followed the previous steps, this will be your Downloads folder) and open the file titled report.txt
m.	Observe any differences.  Use the azure.csv list as the single source of truth; make adjustments as needed. 

End note(s):  Suggest that a periodic review schedule be set (Monthly? Quarterly?).

Relevant Contacts:
Name	Relevancy	Email
Sophie Castel	Author of PBImatch_.R	Sophie.castel@hc-sc.gc.ca
Daniel Durocher	BI Operations specialist	Daniel.r.durocher@hc-sc.gc.ca
Han Tran	BI Operations specialist	Han.tran@hc-sc.gc.ca
BI Operations	Generic inbox	bioperations-operationsbi@hc-sc.gc.ca
