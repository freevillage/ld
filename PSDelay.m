function DistanceFromReceiver = PSDelay( Vp, Vs, PArrivalTime, SArrivalTime )

TimeDifference = SArrivalTime - PArrivalTime;
SlownessP = 1 / Vp;
SlownessS = 1 / Vs;

DistanceFromReceiver = TimeDifference / ( SlownessS - SlownessP );

end % of PSDelay