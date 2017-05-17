
**_ScanImage_** LabVIEW Version
======


-----

+   Author: Zhiping Liu
+   First update:
    Mar. 04, 2017
+   Last Update:
    May 17, 2017

-----

### Mar. 04, 2017

Finished building an $\alpha$ Ver of **_ScanImage_** after
weeks of programming and learning.

Output Channels:

+   **Counter Channel (digital output):**

    Voltage is HIGH (5V) during the sampling period, and
    turns LOW (0V) between two frames. AO and AI channels
    are triggerred by the rising edge of the Counter channel.

    To avoid the physical connection between Counter output
    and the trigger DI (digital input), we used the NI-RTSI
    (Real-Time System Integration), which allow the trigger
    without physica wireline connection.

+   **Analog Output:**

    Outputting two analog signals and controlling the
    x and y direction of galvanometer. X-galvo $V_x$ goes
    from $V_{x, min}$ to $V_{x,max}$ and Y-galvo $V_y$ goes
    from $V_{y,min}$ to $V_{y,max}$.
    $$
    (V_{x})_{i} = Ramp(i, numPerLine)
    \\
    (V_y)_{i} = Ramp(i, numPerFrame)
    $$
    where
    $$
    Ramp(i, j) = mod(i/j)
    $$

+   **Analog Input:**

    Sample the voltage of PD (photodiode) in each pixel.
    Every `Nchan` lines in y direction forms a `channel`.
    data are sent from AI loop to Imaging loop in the
    unit of the packages of a channel.

    ```python
    while True:
        # in a frame
        for channel in range( Ny / Nchan ):
            # in a channel
            for sample in range( Nchan * Nx ):
                sampleAtTick()
        if ExternalInterrupt:
            break
    ```

Setup Parameters:

+   Image size $s$:
The effective pixel of the image is $s \times s$

Using a counter channel as frame trigger, NI-DAQ will output
two channels of analog signal (x and y position of
galvanometer).


Implemented Functionals:

+   AO, AI and DO channels

Unimplemented Functionals:

+   No Physical DO Output

### Mar. 06, 2017

Unit test of different loops:

1)  AI loop
1)  AO loop
1)  DO loop (counter)
1)  Image loop

+   **Triggering AO with DO _(SUCCEEDED)_:**

    Start DO loop infinitely, and wait for DO loop to
    respond. See figure:


    Note that no "Retriggerable" property node is needed to
    realize the retriggering of vi.

### Mar. 8, 2017

Trying to output a digital frame trigger with do channel but
accidentally achieved following fact:

**! VERY IMPORTANT FACT !**

+   _WHENEVER_ `CO` (counter output) is processed, the signal
     will be output physically to `PFI12`!

The $\alpha$ version of the imaging system is basically
finished. Still some works to do:

+   Add the feature of "Stop"
+   Add the feature of "Save"
+   ...

Have a nice day!

### Mar. 11, 2017

Realized saving function.
Tested. OK.

### Mar. 13, 2017

**New demands appended:**

1.  Add an arbitrary delay after frame trigger
    rising edge and before AO/AI channels starts,
    but keep the falling edge of the frame trigger
    synchronized with the end of AI/AO sampling.
    (A shutter with a slow-response is expected
    to be installed)
1.  Change the `Color Map` of the image.
1.  Enable adjustment of `pixel dwelling time(us)`
1.  Fix the distortion of the image using grid sample.

Trying my best to meet those demands.

### Mar. 15, 2017

Fixed a bug about the path of saving file.

**Accomplished demands:**

1.  Arbitrary delay added.
2.  Color Map enabled.
3.  Pixel dwelling time is now adjustable. (us)

**Unfinished features:**

I've been trying to fix the distortion of image by
checking the output of `X/Y channels`. Connect `X/Y
channels` directly and to `AO channel`,
you will find a gradient-colored graph varying in
horizontal and vertical direction respectively.

Save and import these two graphs to `MATLAB`, and plot
every 30 line in the varying direction respectively for
`X` and `Y channel`, its easy to find a family of
perfectly straight line with uniform slope and intercept,
indicating the output and sampling are correct and
well-synchronized.

To cancel the distortion, we seperate a line as such:

$$
N_{line} = N_{return} + N_{head} + N_{sample}
\\
720 = 128 + 80 + 512
$$

where $N_{line}$, $N_{head}$, and $N_{sample}$ denotes
the number of pixel it takes: (1) that galvo return to
initial position for a new line; (2) that imaging system
abandons for accuracy; (3) that the effective samplings
take place, respectively.

The mean reason for such distortion is that the galvo
moves after the electrical signal with a delay $\tau$.

**TO-DO LIST:**

+   Higher AI sample rate.

    Without changing AO rate, and average over multiple
    samplings.

+   Better coloring solution.

### Mar. 28, 2017

Problem confronted:

There is no CO output from `PFI12`. No specific
software and hardware modifications has been done!
Tried with another DAQ card and the same bug
reoccurred.

Trying to find out the reason why `CO` stopped to
output through `PFI12`.

There is a trait called **"Lazy uncommit"**：
The PFI terminal will keep occupied by counter
or digital output until it was assigned another
use.

ref: [lazy uncommit (NI forum)][LazyUncommitLink]

# SOLUTION：

Use a simple vi to run a dummy CO program to
turn the output back to PFI12 (default CO output),
which:

1.  Resets the device with `DAQResetDevice.vi`
2.  Start a `CO` task with no output and no output
    terminal rerouted.

Next steps are making a `initialize.vi` to avoid
such cases and adding it to the program.

### May 17, 2017

Alpha version of the program finished.
New features such as averaged sample and graph mean
value plotting are added.

Ready for further testing. Please see ./data/ for
some images captured with this program!

\
\
\
\
\
\
\
\*\*\*\*\*\*\*

-----


## - * - END OF LOG - * -


-----


[LazyUncommitLink]:https://forums.ni.com/t5/Counter-Timer/Counter-Output-Counter-Input-PXI-Signals-Behaving-Erratically/m-p/3067798
