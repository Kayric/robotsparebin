*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    SeleniumLibrary
Library   OperatingSystem
Library    downloadfile.py
Library    readCSV.py

*** Variables ***
${ORDER_URL}    https://robotsparebinindustries.com/#/robot-order
${CSV_FILE}    https://robotsparebinindustries.com/orders.csv


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close the annoying modal
    Download the order file in CSV format, overwritten to existing file
    Extract the data from the CSV file and fill the order form
    [Teardown]    Close All Browsers
    
*** Keywords ***
Open the robot order website
    Open Browser   ${ORDER_URL}   Chrome
    Maximize Browser Window

Close the annoying modal
    Wait Until Page Contains    I give up all my constitutional rights
    Click Button    //button[@class='btn btn-dark']

Download the order file in CSV format, overwritten to existing file
    Download File    ${CSV_FILE}    orders.csv
Extract the data from the CSV file and fill the order form
    ${orders}=    Read CSV File   orders.csv
    FOR  ${order}  IN  @{orders.to_dict('records')}
    Fill the order from   ${order}
    END


Fill the orderfrom
    [Arguments]    ${order}
    Wait Until Element Is Enabled    //form
    Select From List By Value    //select[@id='head']    ${order['Head']}
    Select Radio Button  body    ${order['Body']}
    Input Text    //input[@type='number']    ${order['Legs']}
    Input Text    //input[@type='text']    ${order['Address']}
    Scroll Element Into View    //footer
    Preview the ordered robot
    Submit the order
    Close the annoying modal

Preview the ordered robot
    Wait Until Element Is Enabled    //button[@id='preview']
    Click Button  //button[@id='preview']
Submit the order
    ${error_message}=  Set Variable    xpath://div[@class='alert alert-danger']
    ${order_button}=  Set Variable    xpath://button[@id='order']
    ${order_another}=  Set Variable    xpath://button[@id='order-another']
    ${order_complete}=  Set Variable    xpath://div[@id='order-completion']
    

    Click Button    ${order_button}

    FOR    ${attempt}    IN RANGE   5 
    TRY
        Page Should Not Contain Element    ${error_message}
        BREAK
    EXCEPT
        Wait Until Page Contains Element    ${error_message}
        Click Button    ${order_button} 
    END
    END
    Store the receipt as a HTML file
    Wait Until Element Is Enabled    ${order_another}
    Click Button    ${order_another}

Store the receipt as a HTML file
    Wait Until Element Is Visible    //div[@id='receipt']
    ${receipt_html}=    Get Element Attribute    //div[@id='receipt']    outerHTML
    ${order_number}=    Get Text    xpath://p[@class='badge badge-success']
    Create File    ${OUTPUT_DIR}${/}${order_number}.html    ${receipt_html}