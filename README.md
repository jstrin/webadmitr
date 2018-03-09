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
    -   [Applicant Level Data with repetion](#applicant-level-data-with-repetion)
        -   [Choices when dealing with applicant level data with repetition](#choices-when-dealing-with-applicant-level-data-with-repetition)
    -   [Applicant Level Data without Repetion](#applicant-level-data-without-repetion)
-   [webadmitr](#webadmitr)
    -   [Export Manager](#export-manager-1)
-   [Useage](#useage)
    -   [Designation/Application Level Data](#designationapplication-level-data-1)
    -   [Applicant Level Data](#applicant-level-data)
    -   [Combined Application and Applicant Level Data](#combined-application-and-applicant-level-data)
    -   [Future Development](#future-development)

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

##### Export Settings

##### Cautionary Notes

When a list is used to export data, the lists filters at the **applicant level**. This means that any information associated with an applicant will appear regardless of the list used. For example, if an applicant applied to a program two years in a row, and the list filters to only one of those years, **data related to both years will appear in the export.** For that reason, I recommend including all fields used in the list in the export as well.

#### Recent Files

Data Useage
-----------

When the data is exported from WebAdMIT, any of the fields that have multiple values are exported. We can classify these broadly into three categories of fields (variables): Applicant Level without Repetition, Applicant Level with Reptition and Designation Level.

<table>
<colgroup>
<col width="29%" />
<col width="38%" />
<col width="31%" />
</colgroup>
<thead>
<tr class="header">
<th>Applicant Level Without Repetion</th>
<th>Applicant Level With Repetion</th>
<th>Designation Level</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Additional Questiosn</td>
<td>All test score fields</td>
<td>Applicant Gateway Activities</td>
</tr>
<tr class="even">
<td>Applicant</td>
<td>College(s) Attended</td>
<td>CAS Information</td>
</tr>
<tr class="odd">
<td>Applicant Ethnicities</td>
<td>GPAs by School</td>
<td>Designation</td>
</tr>
<tr class="even">
<td>Background</td>
<td>GPAs by Transcript</td>
<td></td>
</tr>
<tr class="odd">
<td>Current Mailing Address</td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>Languages</td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>Permanent Mailing Address</td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>Personal</td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>Preferrred Mailing Address</td>
<td></td>
<td></td>
</tr>
</tbody>
</table>

Fields in teh the second two categories, Applicant Level With Repetion and Designation Level will be repeated depending on the population exported (see: "'Many' fields" in the Export Settings section). These fields will be repeated and the column headings appended with "\_n", where "n" is the number of the repetition. The numbering scheme begins with 0 and will go up to a maximum of 9 (10 possible repetitions). \*\*These numbers are not related to any primacy or order; the variable labeled "\_0"" should not take precedence over the variable labeled "\_1" when selecting which values to use.\*\*

### Designation/Application Level Data

For any data field belonging to the Designastion Level Field Categories above, every field will be repeated for each designation created by the applicant. In practice, this means that a single variable (e.g., ag\_extend\_offer\_completed\_date) will be repeated once for every designation created (e.g., ag\_extend\_offer\_completed\_date\_0, ag\_extend\_offer\_completed\_date\_1, ag\_extend\_offer\_completed\_date\_2. In essence, a table is being flattened from one applicant-designation per row to one applicant per row. Each of variable in these three categories should have the same number of entries.

### Applicant Level Data with repetion

Similarly for any data field belonging to the Applicant Level Data with Repetition Field Categories above, every field will be repeated for each entry within each category created by the applicant. In practice, this means that a single variable (e.g., gre\_official\_written\_percentile) will be repeated once for every entry provided by the applicant (or test score provider). If an applicant took the GRE five times, then they would have values represented in five columns. In essence, a table is being flattened from one applicant-entry per row to one applicant per row.

#### Choices when dealing with applicant level data with repetition

Each category needs to be dealt with seperately. For example, you may have 10 columns for submitted GRE scores and only two columns for submitted DAT scores. To combine these different categories effectively, the data must be normalized and transformed so that there is one column per field and one row per applicant.

To accomplish this, I recommend taking each set of fields and choosing the value, per applicant, that makes the most sense for your analysis. For example, if you wanted to look at he GRE percentiles and acceptance rate by program, you would first need to take the GRE score fields and choose the maximum GRE percentile (or average, or median, or whatever) for each applicant. Here is some sample R code for making the above transformaiton:

    library(dplyr)
    library(tidyr)
    library(stringr)

    dfGRE <- read.csv( "webadmit_gre_export.csv", stringsAsFactors = FALSE )

    dfGRE_tidy_written <- dfGRE %>%
        select (student_id, starts_with("gre_official_written_percentile" ),
                  starts_with( "gre_official_quantitative_percentile" ), 
                  starts_with( "gre_official_verbal_percentile" )) %>%
        gather( gre_type, percentile, -student_id ) %>%
        mutate( gre_type_standard = str_sub( gre_type, 1,-3)) %>%
        group_by( student_id, gre_type_standard) %>%
        summarise( m.GRE = max(percentile, na.rm = T)) %>%
        spread( gre_type_standard, m.GRE )
        

### Applicant Level Data without Repetion

The fields in these categories should each appear once per applicant. There should be no duplicated columns.

webadmitr
---------

=======

![](https://github.com/jstrin/webadmitr/images/em_1.JPG, "Screenshot of the Export Manager.")

### Export Manager

Useage
------

### Designation/Application Level Data

### Applicant Level Data

### Combined Application and Applicant Level Data

### Future Development

> > > > > > > d2b1da66b7ee86c21c1407bc5dc060fcf6597ad0
