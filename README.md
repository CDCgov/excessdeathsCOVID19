# Excess Deaths Associated with COVID-19

This project contains the R code to create estimates of excess deaths associated with COVID-19, as published here: https://www.cdc.gov/nchs/nvss/vsrr/covid19/excess_deaths.htm. This program reads in weekly provisional and historic (final) mortality data from 2014 to date, and applies algorithms to estimate the numbers of excess deaths occurring by jurisdiction of occurrence and week since the week ending Feb 1, 2020. 

For more detail about the data and methods, see: https://www.cdc.gov/nchs/nvss/vsrr/covid19/excess_deaths.htm
 
NOTE: estimates produced here may differ slightly from published estimates due to differences in the data sources, timing of data extraction, and years of data included. Previously published estimates used historical data from 2013 to date, while the publicly available data files used in this program include data from 2014 to date. 

# Issues, questions, problems, suggestions

If you have any of the above, please submit an issue on github.

# Requires

- R version >= 4.0.3 (2020-10-10) 
- The following R packages: reshape, tidyr, magrittr, forecast, lubridate, dplyr, surveillance, readr, MMWRweek

# Source Data:

The data are drawn from the two files below, which are updated weekly on Data.CDC.gov:
- https://data.cdc.gov/NCHS/Excess-Deaths-Associated-with-COVID-19/xkkf-xrst
- https://data.cdc.gov/NCHS/Weekly-Counts-of-Deaths-by-State-and-Select-Causes/3yf8-kanr

# Description

Estimates of excess deaths can provide information about the burden of mortality potentially related to COVID-19, beyond the number of deaths that are directly attributed to COVID-19. Excess deaths are typically defined as the difference between observed numbers of deaths and expected numbers. Counts of deaths in more recent weeks are compared with historical trends to determine whether the number of deaths is significantly higher than expected.

Estimates of excess deaths can be calculated in a variety of ways, and will vary depending on the methodology and assumptions about how many deaths are expected to occur. Estimates of excess deaths presented in this webpage were calculated using Farrington surveillance algorithms (1). For each jurisdiction, a model is used to generate a set of expected counts, and the upper bound of the 95% Confidence Intervals (95% CI) of these expected counts is used as a threshold to estimate excess deaths. Observed counts are compared to these upper bound estimates to determine whether a significant increase in deaths has occurred. Provisional counts are weighted to account for potential underreporting in the most recent weeks. However, data for the most recent week(s) are still likely to be incomplete. Only about 60% of deaths are reported within 10 days of the date of death, and there is considerable variation by jurisdiction. More detail about the methods, weighting, data, and limitations can be found in the Technical Notes (https://www.cdc.gov/nchs/nvss/vsrr/covid19/excess_deaths.htm#techNotes).

1. Noufaily A, Enki DG, Farrington P, Garthwaite P, Andrews N, Charlett A. An Improved Algorithm for Outbreak Detection in Multiple Surveillance Systems. Statistics in Medicine 2012;32(7):1206-1222.

# Install & run procedures

Uncomment lines 26-30 to install packages, if required (only necessary the first time the program is run). Then run the R program. The program will create an output csv file 'excessdeaths' with the date of analysis appended to the end of the file name. The output csv file includes the following variables:

- "Week Ending Date"
- "State"
- "Observed Number"
- "Upper Bound Threshold"
- "Exceeds Threshold"
- "Average Expected Count"
- "Excess Lower Estimate"
- "Excess Higher Estimate"
- "Year"
- "Total Excess Lower Estimate"
- "Percent Excess Lower Estimate"
- "Total Excess Higher Estimate"
- "Percent Excess Higher Estimate"
- "Type"
- "Outcome"

This output csv file follows the format of the file published here: https://data.cdc.gov/NCHS/Excess-Deaths-Associated-with-COVID-19/xkkf-xrst/



**General disclaimer** This repository was created for use by CDC programs to collaborate on public health related projects in support of the [CDC mission](https://www.cdc.gov/about/organization/mission.htm).  GitHub is not hosted by the CDC, but is a third party website used by CDC and its partners to share information and collaborate on software. CDC use of GitHub does not imply an endorsement of any one particular service, product, or enterprise. 

  
## Public Domain Standard Notice
This repository constitutes a work of the United States Government and is not
subject to domestic copyright protection under 17 USC § 105. This repository is in
the public domain within the United States, and copyright and related rights in
the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
All contributions to this repository will be released under the CC0 dedication. By
submitting a pull request you are agreeing to comply with this waiver of
copyright interest.

## License Standard Notice
The repository utilizes code licensed under the terms of the Apache Software
License and therefore is licensed under ASL v2 or later.

This source code in this repository is free: you can redistribute it and/or modify it under
the terms of the Apache Software License version 2, or (at your option) any
later version.

This source code in this repository is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the Apache Software License for more details.

You should have received a copy of the Apache Software License along with this
program. If not, see http://www.apache.org/licenses/LICENSE-2.0.html

The source code forked from other open source projects will inherit its license.

## Privacy Standard Notice
This repository contains only non-sensitive, publicly available data and
information. All material and community participation is covered by the
[Disclaimer](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md)
and [Code of Conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md).
For more information about CDC's privacy policy, please visit [http://www.cdc.gov/other/privacy.html](https://www.cdc.gov/other/privacy.html).

## Contributing Standard Notice
Anyone is encouraged to contribute to the repository by [forking](https://help.github.com/articles/fork-a-repo)
and submitting a pull request. (If you are new to GitHub, you might start with a
[basic tutorial](https://help.github.com/articles/set-up-git).) By contributing
to this project, you grant a world-wide, royalty-free, perpetual, irrevocable,
non-exclusive, transferable license to all users under the terms of the
[Apache Software License v2](http://www.apache.org/licenses/LICENSE-2.0.html) or
later.

All comments, messages, pull requests, and other submissions received through
CDC including this GitHub page may be subject to applicable federal law, including but not limited to the Federal Records Act, and may be archived. Learn more at [http://www.cdc.gov/other/privacy.html](http://www.cdc.gov/other/privacy.html).

## Records Management Standard Notice
This repository is not a source of government records, but is a copy to increase
collaboration and collaborative potential. All government records will be
published through the [CDC web site](http://www.cdc.gov).

## Additional Standard Notices
Please refer to [CDC's Template Repository](https://github.com/CDCgov/template)
for more information about [contributing to this repository](https://github.com/CDCgov/template/blob/master/CONTRIBUTING.md),
[public domain notices and disclaimers](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md),
and [code of conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md).
