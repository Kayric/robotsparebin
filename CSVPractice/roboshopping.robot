*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    SeleniumLibrary

*** Variables ***
${ORDER_URL}    https://robotsparebinindustries.com/#/robot-order
${CSV_FILE}    https://robotsparebinindustries.com/orders.csv
${receipt}    xpath://div[@id='order-completion']


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close the annoying modal
    Download the order file in CSV format, overwritten to existing file
    Extract the data from the CSV file and fill the order form
    
    
*** Keywords ***
Open the robot order website
    Open Chrome Browser    ${ORDER_URL}    maximized=${True}

Close the annoying modal
    Wait Until Page Contains    I give up all my constitutional rights
    Click Button    //button[@class='btn btn-dark']

Download the order file in CSV format, overwritten to existing file
        Download    ${CSV_FILE}    overwrite=True
Extract the data from the CSV file and fill the order form
    ${orders}=    Read table from CSV    orders.csv    header=True 
    FOR  ${order}  IN  @{orders}
    Fill the order from   ${order}
    END


Fill the orderfrom
    [Arguments]    ${order}
    Wait Until Element Is Enabled    //form
    Select From List By Value    //select[@id='head']    ${order}[Head]
    Select Radio Button  body    ${order}[Body]
    Input Text    //input[@type='number']    ${order}[Legs]
    Input Text    //input[@type='text']    ${order}[Address]
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
        Exit For Loop
    EXCEPT
        Click Button    ${order_button}
        Sleep    5    # Wait briefly for processing
    END
    END
    Store the receipt as a PDF file
    Wait And Click Button    ${order_another}

Store the receipt as a PDF file
    Wait Until Element Is Visible    //div[@id='receipt']
    ${sales_results_html}=    Get Element Attribute    //div[@id='receipt']    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}sales_results_[Order number].pdf