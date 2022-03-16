# Fitting_MoCap_Data

The code posted here tries to determine the values of the linear 2nd order differential equation approximation of the equations of motion derived from the Lagrangian system. The Lagrangian
system, describes the proximal, middle and distal phalanges of the digits from the level of the metacarpophalangeal joints (Index through little finger) and from the level of the carpometacarpal joint
for the thumb. The kinematic chain is established as a linkage of compound rod pendulums with a constant density of 1.1 g/cm^3. The passive characteristics of the joints like synovial fluid, connective tissue, and tendons that pass through the joints are characterised by a linear torsional spring and damper effects (K, B). 
This code tries to determine the torsional spring and damper constants for each joint in both flexion and abduction. Each joint is manually flexed within its range of motion by the researcher and then it is left to return to its steady state. For the DIP joint since it is mechanically coupled to the PIP joint it was flexed at a smaller angle so that the total PIP excursion was a couple of degrees. For the abduction the digits were all extended to approximately zero degrees and digits were moved towards the midline of the palm and left to return to there steady state. For the abduction of the middle digit, it was moved towards the index finger and it was left to return to its steady state. For more information about the 2nd order differential approximation and how well it can simulate the Lagrangian system for the specified movement see the attached pdf document.


