#include <stdio.h>

double* linsolve10(double *A, double *b);
int main() {
    // Declare a 10x10 matrix
    double A[10][10] = {
        {0.178483, 0.22623, 0.528481, 0.762151, 0.578327, 0.862574, 0.363763, 0.609665, 0.679052, 0.536203},
        {0.185432, 0.287125, 0.69989, 0.553806, 0.582898, 0.902692, 0.774769, 0.0854747, 0.482628, 0.58788},
        {0.638563, 0.595683, 0.880189, 0.89676, 0.0437746, 0.907102, 0.707906, 0.680472, 0.329712, 0.930613},
        {0.387954, 0.295583, 0.978866, 0.248248, 0.922473, 0.811379, 0.0282253, 0.699184, 0.928414, 0.989194},
        {0.993023, 0.382417, 0.425974, 0.575772, 0.965264, 0.720594, 0.32025, 0.0841363, 0.617222, 0.7355},
        {0.110458, 0.942976, 0.200735, 0.392095, 0.0329774, 0.412539, 0.271327, 0.738839, 0.837099, 0.730108},
        {0.705028, 0.919359, 0.452405, 0.806982, 0.795644, 0.627375, 0.840406, 0.827863, 0.322092, 0.279627},
        {0.556032, 0.828123, 0.800858, 0.669235, 0.129693, 0.4565, 0.115638, 0.166419, 0.674075, 0.854157},
        {0.920221, 0.936398, 0.630761, 0.149417, 0.171979, 0.389756, 0.720227, 0.452741, 0.0320552, 0.0443686},
        {0.117645, 0.783674, 0.0640863, 0.157784, 0.284473, 0.370724, 0.299951, 0.331661, 0.918557, 0.740539}
    };

    double b[10] = {  -4.331611661273554,
   9.700949479605548,
  -2.958861449895863,
  -2.116886081675903,
   2.19473734951627,
  14.073247619030543,
  -9.594865957345249,
  -2.447913061477058,
 -10.107200370651855,
   0.8478731362967014};

    linsolve10(A, b);
    for (int i = 0; i < 10; i++) {
        printf("%f\n", b[i]);
    }

    return 0;
}