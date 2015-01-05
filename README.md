Two!Ears Auditory Front-End
===========================

The purpose of the Two!Ears auditory front-end (AFE) is to extract a subset of
common auditory representations from a binaural recording or from a stream of
binaural audio data. These representations are to be used later by higher modeling or
decision stages. The AFE is capable of working in a block-based manner and can
be used as a standalone software or together with other stages of the [Two!Ears
Auditory Model](https://github.com/TWOEARS/TwoEars)

The highlights of AFE are:

* The framework operates on a request-based mechanism and extracts the subset of
  all available representations which has been requested by the user.
* It can operate on a stream of input data. In other words, the framework can
  operate on consecutive chunks of input signal, each of arbitrary length.
* The user request can be modified at run time, i.e., during the execution of
  the framework.


## Installation

The files for the AFE are divided in three folders, `./doc`, `./src` and `./test`
containing respectively the documentation of the framework, the source code,
and various test scripts.
Once Matlab opened, the source code (and if needed the other folders) should be
added to the Matlab path. This can be done by executing the following script in:
```Matlab
>> startAuditoryFrontEnd
```

If you are using the AFE together with other parts of the Two!Ears Auditory
Model, it will automatically be started by
```Matlab
>> startTwoEars
```
Have a look at the documentation of the [Two!Ears
Auditory Model](https://github.com/TWOEARS/TwoEars).

The AFE was developed under Matlab version 8.3.0.532 (R2014a) and tested for backward
compatibility down to Matlab version 8.0.0.783 (R2012b).


## Usage

The AFE is request-based: the user places one or more requests, and then informs the
framework that it should perform the processing. The command `requestList` can
be used to get a summary of all supported auditory representations that can be
requested:
```Matlab
>> requestList
The following requests for Two ! Ears Auditory Front - End processing are
    currently valid :
        'time '
        'filterbank '
        'innerhaircell '
        'adaptation '
        'ams_features '
        'crosscorrelation '
        'autocorrelation '
        'ratemap '
        'ild '
        'itd '
        'ic '
        'spectral_features '
        'onset_strength '
        'offset_strength '
        'pitch '
        'onset_map '
        'offset_map '
        'gabor '
```

The implementation of the AFE is object-oriented, and two objects are needed to
extract any representation:

* A *data* object, in which the input signal, the requested representation, and
  also the
  dependent representations that were computed in the process are all stored.
* A *manager* object which takes care of creating the necessary processors as well
  as
  managing the processing.

### Example of ILD computation

As an example, extracting the interaural level difference `ild` for a stereo
signal `sIn` (e.g., obtained from a `.wav` file through Matlab’s `wavread`) sampled
at a frequency `fsHz` (in Hz) can be done in the following steps:
```Matlab
% Instantiation of data and manager objects
dataObj = dataObject(sIn, fsHz);
managerObj = manager(dataObj);
% Request the computation of ILDs
sOut = managerObj.addProcessor('ild' ;
% Request the processing
managerObj.processSignal;
```

Line 2 and 3 show the instantiation of the two fundamental objects: the data
object and
the manager. Note that the data object is always instantiated first, as the
manager needs
a data object instance as input argument to be constructed. The manager instance
in line
3 is however an "empty" instance of the `manager` class, in the sense that it will
not perform
any processing. Hence a processing needs to be requested, as done in line 6.
This particular
example will request the computation of the inter-aural level difference `ild`.
This step
is configuring the manager instance `managerObj` to perform that type of
processing, but
the processing itself is performed at line 9 by calling the `processSignal` method
of the
manager class.

The request of an auditory representation via the `addProcessor` method of the
manager
class on line 6 returns as an output argument a handle to the requested signal,
here named
`sOut`. In the AFE framework, signals are also objects. For example, for the
output signal
just generated:
```Matlab
>> sOut

sOut =

    TimeFrequencySignal with properties :

      cfHz : [1 x31 double]
     Label : 'Interaural level difference '
      Name : 'ild'
Dimensions : 'nSamples x nFilters '
      FsHz : 100
   Channel : 'mono'
      Data : [267 x31 circVBufArrayInterface ]
      ```
This shows the various properties of the signal object `sOut`. 
To access the computed representation, e.g.,
for further
processing, one can create a copy of the data contained in the signal into a
variable, say
`myILDs`:
```Matlab
>> myILDs = sOut.Data(:);
```
Note the use of the column operator `(:)`. That is because the property .Data of
signal objects is not a conventional Matlab array and one needs this syntax to
access all the values it stores.

### Change parameters for the requested representation

Each individual processors that is supported by the AFE can be controlled by a
set of
parameters. Each parameter can be accessed by a unique *nametag* and has a default
value.
A summary of all parameter names and default values for the individual
processors can be listed by the command `parameterHelper`.
For the `ild` processing the available parameters can be listed with
```Matlab
>> parameterHelper('ild')

Interaural Level Difference parameters:

    Name            Default   Description
    ----            -------   -----------
    ild_wname       'hann'    Window name
    ild_wSizeSec    0.02      Window duration (s)
    ild_hSizeSec    0.01      Window step size (s)
```

It can be seen that the ILD processor can be controlled by three parameters,
namely
`ild_wname`, `ild_wSizeSec` and `ild_hSizeSec`.
A particular parameter can be changed
by
creating a parameter structure which contains the parameter name (*nametags*) and
the
corresponding value. The function `genParStruct` can be used to create such a
parameter
structure. For instance:
```Matlab
>> parameters = genParStruct('ild_wSizeSec', 0.04, 'ild_hSizeSec', 0.02) ;

parameters =
    ild_wSizeSec : 0.0400
    ild_hSizeSec : 0.0200
```
will generate a suitable parameter structure `parameters` to request the
computation of
ILD with a window duration of 40 ms and a step size of 20 ms. This parameter
structure
is then passed as a second input argument in the `addProcessor` method of a
manager
object. The previous example can be rewritten considering the change in
parameter values
as follows:
```Matlab
% Instantiation of data and manager objects
dataObj = dataObject(sIn, fsHz);
managerObj = manager(dataObj);
% Non - default parameter values
parameters = genParStruct('ild_wSizeSec', 0.04, 'ild_hSizeSec', 0.02);
% Place a request for the computation of ILDs
sOut = managerObj.addProcessor('ild', parameters);
% Perform processing
managerObj.processSignal;
```

The ILD processor is further demonstrated by the script `DEMO_ILD.m` in the
`./test` folder.

### More help

The complete functionality of the AFE is discussed in detail in the accompanying
PDF file ...


## Credits

The AFE is developed by Tobias May, Remi Julian Blaise Decorsière from Technical
University of Denmark, Chungeun Kim from University of Technology Eindhoven, and
the rest of the [Two!Ears team](http://twoears.aipa.tu-berlin.de/team).

## License

The AFE under GPL2.

## Funding

This project has received funding from the European Union’s Seventh Framework
Programme for research, technological development and demonstration under grant
agreement no 618075.

![EU Flag](doc/img/eu-flag.gif) [![Tree](doc/img/tree.jpg)](http://cordis.europa.eu/fet-proactive/)
