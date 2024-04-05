*** Settings ***
Resource    ../Resources/resources.robot
Documentation     Downloads the shipping labels generated from 'generate_labels.robot' and renames them based on their PO-number and Label Count by navigating through truecommerce.com and editing the user's local computer's file system, then moves each event into UCC Completed Folder
Library    SeleniumLibrary

*** Variables ***
@{EVENT-NAMES}    # List that will store event names in order of most recently downloaded
${DOWNLOAD-DIRECTORY}=    path\\to\\downloads\\folder

*** Test Cases ***
Get Information From User
    ${is-time-correct}=    Is Time Later Or Equal    10:16 AM    10:16 PM
    ${date-from-user}=    Get Date From User
    ${time-from-user}=    Get Time From User
    ${should-watch-automation}=    Watch Automation Or Not
    Set Suite Variable    ${ASYNCHRONOUS-EVENT-DATE}    ${date-from-user}    # all asynchronous events with this date will be downloaded to '../Downloads'
    Set Suite Variable    ${TIME-ENTERED}    ${time-from-user}    # All events later than this time (and have the same date) will be printed
    Set Suite Variable    ${SHOULD-WATCH-AUTOMATION}    ${should-watch-automation}

Valid Login
    Open Browser To Login Page    ${DOWNLOAD-DIRECTORY}    ${SHOULD-WATCH-AUTOMATION}
    Input Username    ${USERNAME}
    Input The Password    ${PASSWORD}    # Uses an environment variable predefined in VS code 'TRUE_COMMERCE_PASSWORD' for the password used to login
    Submit Credentials
    Welcome Page Should Be Open

Navigate To Viewing Documents
    Click Three Lines
    Run Keyword And Ignore Error    Click Element When It Is Clickable    xpath://div[@title="Stop Walk-thru"]    timeout=3
    Click Transaction Manager
    Click System Activity
    Click Asynchronous Events

Download Shipping Labels
    Wait Until Asynchronous Event Are Loaded
    WHILE    ${True}
        ${length-print-elements-plus-one}=    Length Print Elements Plus One
        FOR    ${index}    IN RANGE    1    ${length-print-elements-plus-one}

            # Click print icon if the user's date they inputted matches the date of the element and the criteria for the time. Account for duplicate elements by checking if we already clicked them
            Wait Until Element Is Clickable    (//i[@class="StatusIconSelect fas fa-print"])[${index}]/../following-sibling::td[5]    timeout=5
            ${date-and-time-text}=    Get Text    (//i[@class="StatusIconSelect fas fa-print"])[${index}]/../following-sibling::td[5]
            ${date-text}=    Date From Date And Time    ${date-and-time-text}
            ${time-text}=    Time From Date And Time    ${date-and-time-text}
            ${is-date-correct}=    Evaluate    '${date-text}' == '${ASYNCHRONOUS-EVENT-DATE}'
            ${is-time-correct}=    Is Time Later Or Equal    ${TIME-ENTERED}    ${time-text}
            IF    ${is-date-correct} and ${is-time-correct}
                ${next-event-name}=    Get Text    (//i[@class="StatusIconSelect fas fa-print"])[${index}]/../following-sibling::td[3]
                ${element-not-in-list}=    Evaluate    '${next-event-name}' not in ${EVENT-NAMES}

                IF    ${element-not-in-list}
                    Click Element When It Is Clickable    (//i[@class="StatusIconSelect fas fa-print"])[${index}]    timeout=5
                    Append To List    ${EVENT-NAMES}    ${next-event-name}
                END
            END
        END
        
        # After printing all elements matching '${ASYNCHRONOUS-EVENT-DATE}' on current page, continue clicking button to next page until there is no next page
        ${disabled-elements}=    Get WebElements    xpath://a[@title="Next Page" and @class="k-link k-pager-nav k-state-disabled"]
        IF    ${disabled-elements}
            BREAK
        ELSE
            Click Element When It Is Clickable    xpath://a[@title="Next Page"]    timeout=5
            Sleep    3s    # Server might not respond immediately after clicking "Next Page"
        END
    END

Rename Pdfs
    # Each Pdf will be named according to their Event Name. If there is more than one event whose names match, only one will be downloaded.
    # All downloads go to '../Downloads' folder

    ${pdf-files}=    List Files In Directory    ${DOWNLOAD-DIRECTORY}    *.pdf    sort=true
    ${index}=    Get Length    ${EVENT-NAMES}

    FOR    ${pdf-file}    IN   @{pdf-files}
        ${index}=    Evaluate    ${index} - 1
        ${old-path}=    Set Variable    ${pdf-file}
        ${new-path}=    Set Variable    ${DOWNLOAD-DIRECTORY}\\${EVENT-NAMES}[${index}].pdf
        Move File    ${old-path}    ${new-path}
    END

Move To UCC Completed Folder
    Click Three Lines
    Click Transaction Manager
    Click Transactions
    Click Outbox

    ${length-list}=    Length Of Elements In Outbox 
    ${length-list-plus-one}=    Evaluate    ${length-list} + 1
    
    # Working under the assumption that all values in outbox are going to have the same "Ship To Type" and "Label Type"
    FOR    ${index}    IN RANGE    1    ${length-list-plus-one}
        Move To UCC Completed Folder    1
        Sleep    3s     # Server doesn't immediately respond to clicking each element
    END