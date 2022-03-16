# Fitting_MoCap_Data

The code posted here tries to determine the values of the linear 2nd order differential equation approximation of the equations of motion derived from the Lagrangian system. The Lagrangian
system, describes the proximal, middle and distal phalanges of the digits from the level of the metacarpophalangeal joints (Index through little finger) and from the level of the carpometacarpal joint
for the thumb. The kinematic chain is established as a linkage of compound rod pendulums with a constant density of 1.1 g/cm^3. The passive characteristics of the joints like synovial fluid, connective tissue, and tendons that pass through the joints are characterised by a linear torsional spring and damper effects (K, B). 
This code tries to determine the torsional spring and damper constants for each joint in both flexion and abduction. Each joint is manually flexed within its range of motion by the researcher and then it is left to return to its steady state. For the DIP joint since it is mechanically coupled to the PIP joint it was flexed at a smaller angle so that the total PIP excursion was a couple of degrees. For the abduction the digits were all extended to approximately zero degrees and digits were moved towards the midline of the palm and left to return to there steady state. For the abduction of the middle digit, it was moved towards the index finger and it was left to return to its steady state. For more information about the 2nd order differential approximation and how well it can simulate the Lagrangian system for the specified movement see the attached pdf document.

# Free response

The data required for this code to work are the free response data of each individual segment of the digits. The free response is attributed to the unloading of the spring component that is part of the passive moment generated at the joints. The experimental procedure was to flex each segment of the digit at some angle and release it. The moment that forces the segment to move is attributed to the loading of the spring like component of the passive moment at each joint. Conceptually, it is equivalent to loading a spring and letting it move about its steady state. 

# Structural Identifiability

An important aspect of experiment design is its structural identifiability. In lay terms, structural identifiability determines whether the parameters of the system are uniquely identified by the specified input-output relationship. The structural identifiability of the system has been explored using the Laplace transform approach as is shown in the pdf document. The free response of the system which characterises the movement of interest is not structurally globally identifiable. That means that there is no adequate information to determine all parameters uniquely, and an a-priori knowledge of at least one of them is essential to uniquely identify the rest. One of the core assumptions of the model which is the cylindrical approximation of the digits is used to determine the moment of inertia of the digits and tha value is being used to identify the remaining parameters B and K. Next the 3 distinct cases of a 2nd order differential equation and thier associated parameter estimation are shown. 

# Overdamped case

In the overdamped case the general solution of the linear 2nd order differential equation is a sum of two exponentials. One is considered to be the slow moving exponential and the other one is the fast moving one. If the system is overdamped the fast moving exponential would reach its steady state within a few microseconds, the data are fitted to a single exponential. By estimating the coefficient of the slow moving exponential then the following equations are used to determine the parameters K and B.

Let the fitted equation to the data be y_fit(t)=a+c*exp(-b*t)

Then the slow moving coefficient is b. The c coefficient is determined from solving the differential equation as

c=rf*(θeq-θ0)/(b-rf) (1)
where θeq and θ0 are the equilibrium and initial angle of the spring component. Since all the parameters are known the fast moving exponential coefficient can be determined from (1).

Once rf is known then the parameters K and B can be determined. From the characteristic polynomial of the differential equation the following two equations are true:

rf*b=K/I (2) and |rf+b|=B/I (3). Since I that corresponds to the segment's moment of inertia is known the parameters K and B can be determined uniquely.

# Underdamped case

For the underdamped damped case the equation that fits the data is yfit(t)=a+c*exp(-b*t)*(d*sin(ω*t)+cos(ω*t)). Solving symbolically the differential equation the parameters b and ω are known and the B,K can determined as follows:

b=B/(2*I) (4)

ω=sqrt(4*K*I-B^2)/(2*I) (5)

Knowing the coefficients b and ω from fitting the data the B and K parameters can be obtained by solving equations 4 and 5 respectivelly.

# Critically damped case

The equation fitting the critically damped case is yfit(t)=a+c*exp(-b*t)*(1+b*t). Solving symbolically the 2nd order differential equation the parameter b is known and the parameters K and B are determined as follows:

b=B/(2*I) (6)

B^2-4*K*I=0 (7)

# How the code works

For the code to work the matlab files found in the repository are important alongside the Template.xlsx file. Download the 2 MATLAB files and and place them in the MATLAB directory. Download and fill the Template.xlsx file. Add in the Fit.m code the directory where you Template.xlsx file is located. Change the sampling frequency fs to correspond to the sampling frequency of your system. 

Next you have to specify how many frames you are interested in looking for fitting the data. Typically I have used somewhere between 50 and 60 frames for mcp pip and dip and 100-120 for the abd. These are specified in the code after the sampling frequency fs.

n -> mcp and pip frames
nab -> abduction frames
n3_1 -> dip frames

Running the code you will be asked to input the number of the digit you are working with. 1 corresponds to the thumb, 2 corresponds to the index finger, 3 to middle, 4 to ring and 5 to little. You have to import manualy the angular data **IN DEGREES** for the segments of each digit as:

dip -> for the most distal segment
pip -> for the middle segment
mcp -> for the proximal segment
abd -> for the abduction movement.

For the thumb its quite hard to get data for flexion/extension of its carpal bone. So for the thumb there is no need to add the mcp angle data. 

Angular data of mcp, pip and dip are filtered using a 4th order low pass Butterworth filter with a cut off frequency of 20 Hz. Abduction angular data are filtered using a 4th order low pass Butterworth filter with a cut off frequency of 5 Hz. The interested reader is refered to the following paper: "https://www.researchgate.net/publication/247159959_Filtering_Motion_Capture_Data_for_Real-Time_Applications".

After filtering the data the code tries to determine the peaks of the signal in order to start the fitting process. **This is the most important part of the code and it may result in errors if not done properly**. The MATLAB function findpeaks is used on the filtered signal. For the mcp pip and dip angles you have to manually add the 'MINPEAKPROMINENCE' value. Make sure that the results you get correspond to the actual peaks of the signal. For the abduction movement its a bit trickier. For all the digits except the middle one, I have moved all digits towards the middle of the palm and then released the digit to return to its steady state. That means that the signal I had to fit started from a lower peak and the steady state was the highest peak of the signal. So for these digits the minus angular data are used to find the peaks. For the middle digit abduction the 'MINPEAKPROMINENCE' is used instead similar to the mcp pip and dip joints. **To avoid any errors I would suggest you run the code once and plot the findpeaks function from the code. Check visually that the peaks of the signal are the ones that correspond to the movement of the segments and then proceed**. Once you have identified the peaks, manually enter the angular data for the digit you are working, then you are ready to run the code. Except for the mcp joint that showed an oscillatory behaviour from the unfiltered data pip, dip and abd angular data are fitted for all 3 cases (underdamped, critically damped and overdamped). **The fit that has the lowest RMSE value is chosen.** K and B parameters are stored into matrices for each segment and the mean values alongside their standard deviation are shown at the end. Alongside the mean spring and damper constant values for each segment the damping ratios are also displayed at the end alongside their standard deviation for each segment.

For the dip data an extra filtering procedure has been added. It has been oberved that filtering the dip angular data at 20 Hz heavily distorted the signal. So the following code has been added. Using the obw function of MATLAB it computes 99% of the occupied bandwidth of the signal between the peak determined from filtering the data at 20 Hz up until 2 times the total frame count you specified for the dip segment.

# Common errors

1) Errors in determining the K and B values because of wrong peak selection. It is quite important for the user to visually verify that the peaks chosen by the code are the ones that correspond to the signal you are trying to fit.
2) Index might exceed the length of the matrix. That error would correspond to the final frame of each signal where the total length of the final angular data exceeds the number of indices of its corresponding matrix. For example, assume that mcp has a length of 1000 indices. You run the code and it determines correctly that the last peak of the signal is at index 960. If you have specified that the signal should have 50 frames then the signal you are trying to fit should be between indices 960 and 1009 of the mcp data. As you can understand since the length of the mcp is only 1000 there are no data between indices 1001 and 1009. Try to reduce the number of frames or change the respective code to not include the last peak.
3) If your code halts for any reason, to get rid of the bar manually, you have to type in the command window delete(f). If not you will always have a bar that you will not be able to close.
