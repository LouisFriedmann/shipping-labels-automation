# shipping-labels-automation
Automate going through truecommerce.com on a specific account to generate shipping labels. This was copied from my internship at basic promotions:

## __Overview__
"Shipping Labels Automation" is a project for an employee at the company "Basic Promotions" used to automatically go through the truecommerce.com website on their account, generate shipping label pdf files, and download them to the 'Downloads' folder for them to use. 'generate_labels.robot' is responsible for generating the shipping labels and after the labels are ready to be downloaded, 'download_files.robot' will download the files for the shipping labels.

## __Technologies/libraries__
Robot Framework, SeleniumLibrary, OperatingSystem, Collections, DateTime, String, and Dialogues.

## __Installation Instructions__
1. If you don't have a recent version of Python installed, install Python [here](https://www.python.org/downloads/) or in the Microsoft store on Windows. Ensure to tick the box that asks if you want to configure a path variable.

2. Install RobotFramework by entering this command into the terminal(For windows: Enter "cmd" into search bar and enter this command):
   ```shell
   pip install robotframework
   ```

3. Clone this repository

## __Run In VS Code First Time__
1. If you don't have VS Code installed, install it [here](https://code.visualstudio.com/download)

2. Open VS Code

3. At the top left corner in VS Code:
   1. Click "File"
   
   2. Click "Open Folder"
   
   3. Navigate to the folder containing all the project files in this cloned repository
   4. Click "Select Folder"
   
4. On the left:
   1. Click "TestCases"
   2. Click "download_files.robot"
   3. Click "generate_labels.robot"

5. In the Variables section of "generate_labels.robot", replace the value of '${DOWNLOAD-DIRECTORY}' with the appropriate directory on your local machine whose path goes into the "Downloads" folder of __this project__.

6. Repeat step 5 in "download_files.robot" instead of "generate_labels.robot"

7. Configure environment variable for called "TRUE_COMMERCE_PASSWORD" that will store the password used to log into truecommerce.com

8. Hold down: ctrl+shift+` to open the terminal on the bottom of VS code if it's not already open

9. Change the directory to the project folder containing TestCases and Resources if you don't see those folders on the left

10. Paste the following command, press enter, and wait until this finishes executing:
   ```shell
   pip install --upgrade robotframework-seleniumlibrary
   ```   

11. Paste the following command and press enter:
   ```shell
   robot -d Output Testcases/generate_labels.robot 
   ```

11. Follow the instructions and then watch the terminal to know what is going on in the program. If 0 testcases fail at the end, move onto the next step AFTER ALL ASYNCHRONOUS EVENTS ARE SUCCESSFUL AND YOUVE CHECKED TO ENSURE THE DOWNLOADS FOLDER IS EMPTY EXCEPT FOR THE INFO FILE. Otherwise, there is a bug somewhere. 

12. Paste the following command and press enter:
   ```shell
   robot -d Output Testcases/download_files.robot 
   ```

13. Repeat step 11 (except don't move onto the next step because after 'download_files.robot' is ran, you're done).

## __Run In VS Code After First Time__
1. Open VS Code
   
2. If no folder is open on the left, repeat step 3 in "Run In VS Code First Time"

3. Hold down: ctrl+shift+` to open the terminal on the bottom of VS code if it's not already open

4. Follow steps 10 and onward in "Run In VS Code First Time"
