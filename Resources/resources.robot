*** Settings ***
Documentation     Contains variables and keywords to navigate through truecommerce.com
Library    SeleniumLibrary
Library    BuiltIn
Library    OperatingSystem
Library    Collections
Library    DateTime
Library    String
Library    Dialogs

*** Variables ***
${LOGIN-URL}=      https://foundry.truecommerce.com/core/Default.html
${BROWSER}=        Chrome
${USERNAME}=       YourUsername

# Uses an environment variable predefined in VS code 'TRUE_COMMERCE_PASSWORD' for the password
${PASSWORD}=       %{TRUE_COMMERCE_PASSWORD} 
${SHIP-NOTICE-ELEMENTS}

*** Keywords ***
# Helper Keywords

Wait Until Element Is Clickable
    [Arguments]    ${xpath}    ${timeout}
    Wait Until Element Is Enabled    ${xpath}    timeout=${timeout}
    Wait Until Element Is Visible    ${xpath}    timeout=${timeout}

Click Element When It Is Clickable
    [Arguments]    ${xpath}    ${timeout}
    Wait Until Element Is Clickable    ${xpath}    ${timeout}
    Click Element    ${xpath}

Double Click Element When Clickable
    [Arguments]    ${element}
    Wait Until Element Is Clickable    ${element}    timeout=30
    Double Click Element    ${element}

Wait Until Print Is Ready
    # Once print notification pops up, we are ready to print Asynchronous labels

    ${is-ready-notifications}=    Get WebElements    xpath://div[contains(text(), "The label list was successfully retrieved for 1 transaction")]
    ${length-is-ready-notifications}=    Get Length    ${is-ready-notifications}
    ${not-is-ready-notifications}=    Evaluate    ${length-is-ready-notifications} <= 0

    WHILE    ${not-is-ready-notifications}
        Sleep    1s
        ${is-ready-notifications}=    Get WebElements    xpath://div[contains(text(), "The label list was successfully retrieved for 1 transaction")]
        ${length-is-ready-notifications}=    Get Length    ${is-ready-notifications}
        ${not-is-ready-notifications}=    Evaluate    ${length-is-ready-notifications} <= 0
    END

# Login

Open Browser To Login Page
    [Arguments]    ${default-download-directory}    ${should-watch-automation}
    ${prefs}=    Create Dictionary    download.default_directory=${default-download-directory}    download.prompt_for_download=${FALSE}  plugins.always_open_pdf_externally=${TRUE}
    ${chrome_options}=    Evaluate    selenium.webdriver.ChromeOptions()    selenium.webdriver
    Call Method    ${chrome_options}    add_argument    --start-maximized
    Run Keyword If    not ${should-watch-automation}    Call Method    ${chrome_options}    add_argument    --headless
    Call Method    ${chrome_options}    add_experimental_option    prefs    ${prefs}
    Create Webdriver    Chrome    options=${chrome_options}
    Go To    ${LOGIN-URL}
    Wait Until Element Is Clickable    xpath://span[@data-bind="text: currentVM().title"]    timeout=60
    ${span_text}=    Get Text    xpath://span[@data-bind="text: currentVM().title"]
    Should Be Equal As Strings    ${span_text}    Sign In

Input Username
    [Arguments]    ${username}
    Wait Until Element Is Clickable    xpath://input[@placeholder='User Name']    timeout=10
    Input Text    xpath://input[@placeholder='User Name']    ${username}

Input The Password
    [Arguments]    ${password}
    Wait Until Element Is Clickable    xpath://input[@placeholder='Password']    timeout=10
    Input Text    xpath://input[@placeholder='Password']    ${password}

Submit Credentials
    Wait Until Element Is Clickable    xpath://button[text()='Login']    timeout=10
    Click Button    xpath://button[text()='Login']

Welcome Page Should Be Open
    Title Should Be    Foundry

# Navigate to Outbox

Click Transaction Manager
    Click Element When It Is Clickable    xpath://span[text()="Transaction Manager"]    timeout=5

Click Transactions
    Click Element When It Is Clickable   xpath://span[text()="Transactions"]    timeout=5

Click Outbox
    Click Element When It Is Clickable    xpath://span[text()="Outbox"]    timeout=30

Length Of Elements In Outbox
    Wait Until Element Is Clickable    xpath://*[@id="Transactions"]/div[2]/div/div[2]/table/tbody    timeout=5
    @{SHIP-NOTICE-ELEMENTS}=    Get WebElements    xpath://td[contains(text(), "Ship Notice/Manifest")]
    ${length-list}=    Get Length    ${SHIP-NOTICE-ELEMENTS}
    RETURN    ${length-list}

# "Ship To Type" and "Label Type"

Fill Ship To Type
    [Arguments]    ${ship-to-type}
    Click Element When It Is Clickable    xpath://*[@id="T2748"]    timeout=5
    Sleep    1s
    Click Element When It Is Clickable    xpath://li[normalize-space(text())=${ship-to-type}]     timeout=5

Fill Label Type
    [Arguments]    ${label-type}
    Sleep    3s    # Wait extra time for label type to fully load
    Click Element When It Is Clickable    xpath://*[@id="T4139"]    timeout=5
    Sleep    1s
    Click Element When It Is Clickable    xpath://li[normalize-space(text())=${label-type}]    timeout=5

Save And Close
    Click Element When It Is Clickable    xpath://span[text()="Save & Close"]    timeout=5

Click Back Arrow
    Click Element When It Is Clickable    xpath://i[@class="fa fa-angle-left fa-stack-1x"]    timeout=5

Fill Ship To Type And Label Type
    [Arguments]    ${ship-to-type}    ${label-type}
    Run Keyword And Ignore Error    Wait Until Element Is Clickable     xpath://*[normalize-space(text())=${ship-to-type}]    timeout=5
    ${is-store-filled-in}=    Run Keyword And Return Status    Element Should Be Visible    xpath://*[normalize-space(text())=${ship-to-type}]

    Run Keyword And Ignore Error    Wait Until Element Is Clickable     xpath://*[normalize-space(text())=${label-type}]   timeout=5
    ${is-standard-filled-in}=    Run Keyword And Return Status    Element Should Be Visible    xpath://*[normalize-space(text())=${label-type}]

    IF    ${is-store-filled-in} and ${is-standard-filled-in}
        Click Back Arrow
        ELSE
            IF    ${is-store-filled-in}
                Fill Label Type    ${label-type}
            ELSE IF    ${is-standard-filled-in}
                Fill Ship To Type    ${ship-to-type}
            ELSE
                Fill Ship To Type    ${ship-to-type}
                Fill Label Type    ${label-type}
            END
            Save And Close
        END

# Asynchronous Events

Click System Activity
    Click Element When It Is Clickable    xpath://span[text()="System Activity"]    timeout=5

Click Asynchronous Events
    Click Element When It Is Clickable    xpath://span[text()="Asynchronous Events"]    timeout=5

Length Print Elements Plus One
    ${print-elements}=    Get WebElements    xpath://i[@class="StatusIconSelect fas fa-print"]
    ${length-list}=    Get Length    ${print-elements}
    ${length-list-plus-one}=    Evaluate    ${length-list} + 1
    RETURN    ${length-list-plus-one}


Wait Until Asynchronous Event Are Loaded
    # Reload page. Not all elements to print are loaded when the page loads for the first time. Most times, the reload button is clicked to get to reload the page and get all the elements
    Click Element When It Is Clickable    xpath://span[@class="k-icon k-i-reload"]    timeout=60

    # Wait until page has reloaded
    Wait Until Page Contains Element    xpath://i[@class="fa fa-circle-o-notch fa-spin fa-4x fa-fw"]    timeout=30
    Wait Until Page Does Not Contain Element    xpath://i[@class="fa fa-circle-o-notch fa-spin fa-4x fa-fw"]    timeout=60
    Wait Until Element Is Clickable    xpath://i[@class="StatusIconSelect fas fa-print"][1]    timeout=60
    Wait Until Element Is Clickable    xpath://div[text()="Asynchronous Events Loaded."]    timeout=60

# Prompting User

Get Ship To Type From User
    ${ship-to-type}=    Get Selection From User    Select Ship To Type:    Store    Distribution Center
    RETURN    ${ship-to-type}

Get Label Type From User
    ${label-type}=    Get Selection From User    Select Label Type:    Pick and Pack    Pick and Pack with Content Label    Standard    Standard Bulk with Vendor Style Number    Standard Assortment    Pick and Pack Prepack
    RETURN    ${label-type}

Get Date From User
    ${value-from-user}=    Get Value From User    Enter the date of the asynchronous events that you want to download in the format M/D/Y WITHOUT leading zeros(ex:3/27/2024). If no date is entered, the date will default to today's date:
    ${date}=    Set Variable    ${value-from-user}
    ${is-date-empty}=    Evaluate    not '${date}'
    IF    ${is-date-empty}
        ${current-date}=    Get Current Date    result_format=%#m/%#d/%Y
        ${date}=    Set Variable    ${current-date}
    END
    RETURN    ${date}

Get Time From User
    ${time-str}=    Get Value From User    Enter the submission time where all events equal to and later than this time (and equal to the date entered) will be printed. Must have no leading zeros and be in the format shown in this example: (ex: 12:38 PM)
    RETURN    ${time-str}

Watch Automation Or Not
    ${yes-or-no}=    Get Selection From user    Would you like to watch the automation? Yes: have it full screen in a chrome window. No: The automation won't be visible in a chrome window.    Yes    No
    ${should-watch-automation}=    Evaluate    '${yes-or-no}' == "Yes"
    RETURN    ${should-watch-automation}

# Other

Click Three Lines
    Click Element When It Is Clickable    xpath://*[@id="menuButtonToggle"]    timeout=30

Print Asynchronous Labels
    [Arguments]    ${PO-number}
    Click Element When It Is Clickable    xpath://span[text()="Print"]    timeout=5
    Click Element When It Is Clickable    xpath://span[text()="Labels"]    timeout=5
    Click Element When It Is Clickable    xpath://span[text()="Asynchronous Labels"]    timeout=5
    Input Text    xpath://input[@placeholder="Label Print"]    ${PO-number}
    Click Element When It Is Clickable    xpath://button[text()="Start Event"]    timeout=5
    Wait Until Print Is Ready
    Click Element When It Is Clickable    xpath://span[text()="Print"]    timeout=60

Date From Date And Time
    [Arguments]    ${date-and-time}
    ${start-idx}=    Set Variable    0
    ${end-idx}=    Evaluate    '${date-and-time}'.find(' ')
    ${date}=    Get Substring    ${date-and-time}    ${start-idx}    ${end-idx}
    RETURN    ${date}

Time From Date And Time
    [Arguments]    ${date-and-time}
    ${start-idx}=    Evaluate    '${date-and-time}'.find(' ') + 1
    ${time}=    Get Substring    ${date-and-time}    ${start-idx}
    RETURN    ${time}

Move To UCC Completed Folder
    [Arguments]    ${index}    # Index of element we are looking at
    Click Element When It Is Clickable    (//td[contains(text(), "Ship Notice/Manifest")])[${index}]    timeout=5
    Click Element When It Is Clickable    xpath://span[text()="Options"]    timeout=5
    Click Element When It Is Clickable    xpath://span[text()="Move To ..."]    timeout=5
    Click Element When It Is Clickable    xpath://span[@data-bind="text: text" and text()="UCC completed"]    timeout=5
    Sleep    1s    # Notifications might block the text or the server might take a second to respond after clicking "UCC completed"
    Click Element When It Is Clickable    xpath://button[text()="OK"]    timeout=5

# Checks if time2 is later than or equal to time1
Is Time Later Or Equal
    [Arguments]    ${time1}    ${time2}
    ${is-time1-morning}=    Evaluate    'AM' in '${time1}'
    ${is-time2-morning}=    Evaluate    'AM' in '${time2}'
    ${is-time1-afternoon}=    Evaluate    'PM' in '${time1}'
    ${is-time2-afternoon}=    Evaluate    'PM' in '${time2}'

    IF    ${is-time1-morning} and ${is-time2-morning} or ${is-time1-afternoon} and ${is-time2-afternoon}
        ${time1-number}=    Evaluate    int('${time1}'[:'${time1}'.index(":")] + '${time1}'['${time1}'.index(":") + 1:'${time1}'.index(" ")])
        ${time2-number}=    Evaluate    int('${time2}'[:'${time2}'.index(":")] + '${time2}'['${time2}'.index(":") + 1:'${time2}'.index(" ")])
        ${is-time2-later}=    Evaluate    ${time2-number} >= ${time1-number}
        RETURN    ${is-time2-later}
    ELSE IF    ${is-time1-morning} and ${is-time2-afternoon}
        RETURN    ${True}
    ELSE
        RETURN    ${False}
    END