*** Settings ***
Documentation     Insert the sales data for the week and export it as a PDF
Library   SeleniumLibrary
Library  download_excel.py
Library  read_excel.py
Library   OperatingSystem

*** Tasks ***
Insert the sales data for the week and export it as a HTML
    [Documentation]     User logged in to intranet and download the sales report in excel format 
    ...    and input the data from the file into the input form
    ...    then capture the summary and export the sales result in HTML format
    Open intranet and download data
    Submit Sales Data From Excel File
    Export results as HTML

*** Keywords ***
Open intranet and download data
    [Documentation]    Open the intranet website and download the Excel file
    Open Browser    https://robotsparebinindustries.com/    chrome
    Maximize Browser Window
    Log in
    Download File    https://robotsparebinindustries.com/SalesData.xlsx    SalesData.xlsx

Log in
    [Documentation]    Log in to the intranet website
    Input Text    //input[@id="username"]    maria
    Input Password    //input[@id="password"]    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    //form[@id='sales-form']

Submit Sales Data From Excel File
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

Export results as HTML
    [Documentation]    Capture the summary and export it as a PDF
    Wait Until Page Contains Element    //div[@class="alert alert-dark sales-summary"]
    Capture Element Screenshot    //div[@class="alert alert-dark sales-summary"]    ${OUTPUT_DIR}${/}sales_summary.png
    Wait Until Page Contains Element    //div[@id='sales-results']
    ${sales_results_html}=    Get Element Attribute    //div[@id='sales-results']    outerHTML
    Create File    ${OUTPUT_DIR}${/}sales_results.html    ${sales_results_html}

