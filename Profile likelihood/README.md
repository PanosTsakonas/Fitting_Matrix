# Profile likelihood using the D2D software in MATLAB

To use this code you will need to have the D2D software installed in MATLAB. You can find the D2D software here (https://github.com/Data2Dynamics/d2d).
Once you have downloaded the software navigate to C:\......\arFramework3\Examples and create a new folder. Within that folder you will need to create a Data and a Models folders.
In the Data folder copy the New_data.def and the csv file New_data.csv. In the Models folder copy the IBK_rev.def file. Once everything is done then simply run the Profile_Likelihood_Fit_Comparison.m. 

You need to load the values of the moments of inertia of the finger you are examining alongside the raw data for the MCP, PIP, DIP and Abduction finger segment movements.

Then the software will filter these will find the peaks and will perform the fitting of the data using MATLAB's build in fit function and the Profile Likelihood approach. In the end it will plot the two different fits with the filtered data and a tale showing the determined values will appear as well.

You must specify the directories in which the Data and Models file have been created in the calculations.m script. In the Profile_Likelihood_Fit_Comparison.m file you need to specify the directory where the moments of inertia excel file is located.

When everything is done then the code should run with no problem. Once your data are there then the code will create the necessary excel files in the Data folder which is based on finding the peaks from the filtered data and taking the next 60 indices. It will the updae automatically the New_data.def and IBK_rev.def files automatically based on the new initial angular position, equilibrium angle, and moment of inertia. 

# If you are not using a MoCap sampling frequency of 150 Hz you must change in both the IBK_rev.def and New_data.def files in the PREDICTOR section the duration of your experiment. In my case I had a sampling frequency of 150 Hz and I took 60 data point with the duration of my experiment being 0.3933. If you want more data points or have a different sampling frequency change the respective files otherwise the code will not give correct values.  
