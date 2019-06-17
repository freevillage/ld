clockShifts = 0 : 500 : 4500;
totalClockShifts = length( clockShifts );

for jClockShift = 1 : totalClockShifts
    clockShiftAverage = clockShifts(jClockShift);
    test_moving_platform_3towers_mc;
end