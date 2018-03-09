webadmitr
================
John Stringer
March 9, 2018

-   [Background](#background)
    -   [WebAdMIT](#webadmit)
        -   [Naming Conventions in WebAdMIT/Liaison](#naming-conventions-in-webadmitliaison)
        -   [List Manager](#list-manager)
        -   [Export Manager](#export-manager)
        -   [Recent Files](#recent-files)
-   [Data Useage](#data-useage)
    -   [Designation/Application Level Data](#designationapplication-level-data)
    -   [Applicant Level Data](#applicant-level-data)
    -   [Combined Application and Applicant Level Data](#combined-application-and-applicant-level-data)

Background
----------

WebAdMIT is admissions management software available from [Liaison International](https://www.liaisonedu.com/admission-management-system/). The tool is designed to help academic programs and admissions offices to process applications through admissions lifecycle. While there are a number of learning modules provided by Liaison (available [here](http://elearning.easygenerator.com/2567be59-4299-474d-98ea-6cd71551cf76/#login) ), what to do with the data once exported is not part of the training. I created this document and accompanying R package to help users understand and process the data.

*Notes: * - Some of what is covered here will be redundant from the Liaison training, however, it is necesary to include it to provide context for the rest of the documentaiton. - This doucmentation and code was developed at Boston University around BU's implementation of [UniCAS<sup>TM</sup>](https://www.liaisonedu.com/centralized-application-service/). Some, if not all, of the code and use cases may not be directly applicable to your implementation of WebAdMIT. - This is a living document and will continue to evolve, feel free to email me with suggestions or queistions.

### WebAdMIT

WebAdMIT's primary function is a workflow tool for the processing of applicatioins. This base funcitonality has been expanded upon to include the export of application data for use in analysis and for integration with Student Information Systems (SIS). While there is an API available for programatic interatiction with the database, this documentation will only address manual exports.

There are two tools in WebAdMIT that we use for the manual export of data: the List Manager and the Export Manager. As their names suggest, the List Manager is a tool that allows the user to create lists of applicants based on a variety of criteria. The Export Manager is a tool that allows the user to specify which data to export, and to some extent, how that data should be formatted.

##### Naming Conventions in WebAdMIT/Liaison

Some of the naming conventions in WebAdMIT/Liaison can be confusing. Below is a table that includes some of the terminology I have found to cause the most problems. I will do my best to use consistent terminology in this document.

<table>
<colgroup>
<col width="16%" />
<col width="37%" />
<col width="46%" />
</colgroup>
<thead>
<tr class="header">
<th>WebAdMIT Term</th>
<th>Definition</th>
<th>Notes</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>CAS<sup>TM</sup></td>
<td>Credential Assembly Services</td>
<td>generally used to refer an implementation of the applicaiton</td>
</tr>
<tr class="even">
<td>Cycle</td>
<td>Year in which the application is active</td>
<td>The naming convention Liaison uses is two years (e.g., 2016-2017). However, this is not the academic year, rather it is the calendar year of the second year listed. For example, the 2016-2017 cycle is the 2017 calendar year, which included applications to Spring 2017, Summer 2017, and Fall 2017.</td>
</tr>
<tr class="odd">
<td>Designation</td>
<td>program to which an applicant is applying</td>
<td>Designation closely aligns with BU's definition of proram of study. However, it is possible that multiple designations will map to the same program of study. Throughout this document, designation is used to refer to the Liaison defined designation and application is used more generally to refer to all application materials. This distinction becomes important when dealing with export creation and exported data.</td>
</tr>
</tbody>
</table>

#### List Manager

You can access the List Manager from the menus on the left hand side of WebAdMIT. When you first open the List Manager, you should see a table with 5 columns and 3 headings "List Name", "Type", "Show on Toolbar". The first column contains an icon with 6 squares arranged in a square grid. You can use this to arrange the order of the rows in the table. The last column contians a series of icons that act as short cuts to various actions.

\[INSERT TABLE WITH IMAGEs OF ICONS AND CORRESPONDING ACTIONS\]

There are two types of lists, "Field" and "Composite." Field lists use data in the applciaiton records to filter applicants; there does not appear to be a limit to the number of fields you can add to a list. Composite lists use combinations of field lists to filter on multiple conditions at once; composite lists can include at most 5 field lists.

Please note that each field list can only be configured to filter applicants meeting all or any of the conditions provided. For example, to create a list of **all** international applicants who are applying to basket weaving **or** cat herding, it is necessary to create two seperate field lists then combine them into a composite list. The first filtering to all international applicants the second that filters to any applicant applying to basket weaving or cat herding. The composite list would then filter to any applicants that appear in both field lists

##### List Options

When creating a new list, there four options presented:

<table>
<colgroup>
<col width="10%" />
<col width="15%" />
<col width="74%" />
</colgroup>
<thead>
<tr class="header">
<th>Option</th>
<th>Default Value</th>
<th>recommendation/context</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>List Name</td>
<td>blank</td>
<td>choose something short and meaningful</td>
</tr>
<tr class="even">
<td>appear in toolbar</td>
<td>&quot;will not&quot;</td>
<td>if you change to &quot;will&quot;, the list name will apear on the left handside under Applicant Lists. Only do this if you will be accessing the list on a regular basis.</td>
</tr>
<tr class="odd">
<td>settings can be seen by</td>
<td>&quot;only myself&quot;</td>
<td>At present, lists can only be shared with everyone or no one. Unless your entire organization needs access to the list, I recommend leaving it as is.</td>
</tr>
<tr class="even">
<td>Applicants match</td>
<td>&quot;all&quot;</td>
<td>&quot;all&quot; means that every condition specified must be met for an applicant to be included in the resulting list. &quot;any&quot; means that any applicant that meets at least one of the specified condtions will be included in the result.</td>
</tr>
</tbody>
</table>

![alt text](https://github.com/jstrin/webadmitr/raw/master/images/field_list_1.JPG "Image of the Field List Creation Screen")

#### Export Manager

![alt text](https://github.com/jstrin/webadmitr/raw/master/images/em_1.JPG "Screenshot of the Export Manager")

##### Cautionary Notes

When a list is used to export data, the lists filters at the **applicant level**. This means that any information associated with an applicant will appear regardless of the list used. For example, if an applicant applied to a program two years in a row, and the list filters to only one of those years, **data related to both years will appear in the export.** For that reason, I recommend including all fields used in the list in the export as well.

#### Recent Files

Data Useage
-----------

When the data is exported from WebAdMIT, any of the fields that have multiple values are exported. We can classify these broadly into two categories: Applicant Level and Designation Level.

| Applicant Level Field Categories | Designation Level Field Categories |
|----------------------------------|------------------------------------|
| Additional Questiosn             | Applicant Gateway Activities       |
| Applicant                        | CAS Information                    |
| Applicant Ethnicities            | Designation                        |
| All test scores fields           |                                    |
| Background                       |                                    |
| College(s) Attended              |                                    |
| Current Mailing Address          |                                    |
| GPAs by School                   |                                    |
| GPAs by Transcript               |                                    |
| Languages                        |                                    |
| Permanent Mailing Address        |                                    |
| Personal                         |                                    |
| Preferrred Mailing Address       |                                    |

### Designation/Application Level Data

E

### Applicant Level Data

### Combined Application and Applicant Level Data
