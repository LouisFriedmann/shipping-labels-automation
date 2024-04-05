*** Settings ***
Resource    ../Resources/resources.robot
Documentation     Generates shipping labels to download in 'download_files.robot' by navigating through truecommerce.com

*** Variables ***
${DOWNLOAD-DIRECTORY}=    path\\to\\downloads\\folder

*** Test Cases ***
Get Information From User
    ${ship-to-type-from-user}=    Get Ship To Type From User
    ${label-type-from-user}=    Get Label Type From User
    ${should-watch-automation}=    Watch Automation Or Not
    Set Suite Variable    ${SHIP-TO-TYPE}    ${ship-to-type-from-user}
    Set Suite Variable    ${LABEL-TYPE}    ${label-type-from-user}
    Set Suite Variable    ${SHOULD-WATCH-AUTOMATION}    ${should-watch-automation}

Valid Login
    Open Browser To Login Page    ${DOWNLOAD-DIRECTORY}    ${SHOULD-WATCH-AUTOMATION}
    Input Username    ${USERNAME}
    Input The Password    ${PASSWORD}    # Uses an environment variable predefined in VS code 'TRUE_COMMERCE_PASSWORD' for the password used to login
    Submit Credentials
    Welcome Page Should Be Open

Navigate To Outbox
    Click Three Lines
    Run Keyword And Ignore Error    Click Element When It Is Clickable    xpath://div[@title="Stop Walk-thru"]    timeout=3
    Click Transaction Manager
    Click Transactions
    Click Outbox

Fill In Fields To List From Outbox
    ${length-list}=    Length Of Elements In Outbox 
    ${length-list-plus-one}=    Evaluate    ${length-list} + 1
    
    # Working under the assumption that all values in outbox are going to have the same "Ship To Type" and "Label Type" that are inputted by the user
    FOR    ${index}    IN RANGE    1    ${length-list-plus-one}
        ${next-element-xpath}=    Set Variable    (//td[contains(text(), "Ship Notice/Manifest")])[${index}]
        Click Element When It Is Clickable    ${next-element-xpath}    timeout=5

        # Retrieve PO-number from each element to use in 'Print Asynchronous Labels'
        Wait Until Element Is Clickable    (//td[contains(text(), "Ship Notice/Manifest")])[${index}]/following-sibling::td[3]    timeout=5
        ${PO-number}=    Get Text    (//td[contains(text(), "Ship Notice/Manifest")])[${index}]/following-sibling::td[3]
        Double Click Element When Clickable    (//td[contains(text(), "Ship Notice/Manifest")])[${index}]
        
        Fill Ship To Type And Label Type    '${SHIP-TO-TYPE}'    '${LABEL-TYPE}'
        Sleep    5s    # Server doesn't immediately respond after filling in "Ship To Type" and "Label Type"
        Sleep    2s    # Ensure the correct element is clicked for printing
        Print Asynchronous Labels    ${PO-number}
        Sleep    5s    # Server doesn't immediately respond when going from one element to clicking the next element in outbox
        Click Back Arrow
    END