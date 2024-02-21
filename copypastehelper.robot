*** Settings ***
Documentation       Insert the sales data for the week and export it as a PDF
Library    SeleniumLibrary
Library    download_excel.py
Library    read_excel.py

*** Tasks ***
Insert the sales data for the week and export it as a PDF
    Open intranet and download data
    Collect and submit sales data
    #Export results as PDF

*** Keywords ***
Open intranet and download data
    [Documentation]    Open the intranet website and download the Excel file
    Open Browser    https://robotsparebinindustries.com/    chrome
    Log in
    Download File    https://robotsparebinindustries.com/SalesData.xlsx    SalesData.xlsx

Log in
    [Documentation]    Log in to the intranet website
    Input Text    //input[@id="username"]    maria
    Input Password    //input[@id="password"]    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    //form[@id='sales-form']

Collect and submit sales data
    [Documentation]    Fill and submit the form for each sales rep in the downloaded Excel file
    ${sales_reps}=    Read Excel Data    SalesData.xlsx
    FOR    ${row}    IN    @{sales_reps.to_dict('records')}
    Fill form with sales rep data    ${row}
    END

Fill form with sales rep data
    [Arguments]    ${row}
    Input Text    //input[@id="firstname"]    ${row['First Name']}
    Input Text    //input[@id="lastname"]    ${row['Last Name']}
    Select From List By Value    //select[@id="salestarget"]    ${row['Sales Target']}
    Input Text    //input[@id="salesresult"]    ${row['Sales']}
    Click Button    Submit
    Wait Until Page Contains Element    //div[@id='sales-results']

#Export results as PDF
#     [Documentation]    Capture the summary and export it as a PDF
#     Wait Until Page Contains Element    //div[@class="alert alert-dark sales-summary"]
#     Capture Element Screenshot    //div[@class="alert alert-dark sales-summary"]    ${OUTPUT_DIR}${/}sales_summary.png
#     Wait Until Page Contains Element    //div[@id='sales-results']
#     ${sales_results_html}=    Get Element Attribute    //div[@id='sales-results']    outerHTML
#     Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}sales_results.pdf

