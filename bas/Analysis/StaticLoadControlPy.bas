
*format "%f"
Lincr = *LoadIncr
*format "%d"
Nsteps = *steps
committedSteps = 1
LoadCounter = 0

strIni = ""
*if(strcmp(IntvData(Convergence_criterion),"Norm_Unbalance")==0)
testTypeStatic = 'NormUnbalance'
*elseif(strcmp(IntvData(Convergence_criterion),"Norm_Displacement_Increment")==0)
testTypeStatic = 'NormDispIncr'
*elseif(strcmp(IntvData(Convergence_criterion),"Energy_Increment")==0)
testTypeStatic = 'EnergyIncr'
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Unbalance")==0)
testTypeStatic = 'RelativeNormUnbalance'
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Displacement_Increment")==0)
testTypeStatic = 'RelativeNormDispIncr'
*elseif(strcmp(IntvData(Convergence_criterion),"Total_Relative_Norm_Displacement_Increment")==0)
testTypeStatic = 'RelativeTotalNormDispIncr'
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Energy_Increment")==0)
testTypeStatic = 'RelativeEnergyIncr'
*elseif(strcmp(IntvData(Convergence_criterion),"Fixed_Number_of_Iterations")==0)
testTypeStatic = 'FixedNumIter'
*endif

*format "%g"
TolStatic = *IntvData(Tolerance,real)
maxNumIterStatic = *IntvData(Max_Iterations_per_Step,int)
*if(strcmp(IntvData(Solution_algorithm),"Full_Newton-Raphson")==0)
algorithmTypeStatic = 'Newton'
*if(IntvData(Use_initial_stiffness_iterations,int)==1)
strIni = "/Ini"
*endif
*elseif(strcmp(IntvData(Solution_algorithm),"Modified_Newton-Raphson")==0)
algorithmTypeStatic = 'ModifiedNewton'
*if(IntvData(Use_initial_stiffness_iterations,int)==1)
strIni = "/Ini"
*endif
*elseif(strcmp(IntvData(Solution_algorithm),"Newton-Raphson_with_line_search")==0)
algorithmTypeStatic = 'NewtonLineSearch'
*elseif(strcmp(IntvData(Solution_algorithm),"Broyden")==0)
algorithmTypeStatic = 'Broyden'
*elseif(strcmp(IntvData(Solution_algorithm),"BFGS")==0)
algorithmTypeStatic = 'BFGS'
*elseif(strcmp(IntvData(Solution_algorithm),"KrylovNewton")==0)
algorithmTypeStatic = 'KrylovNewton'
*if(IntvData(Use_initial_stiffness_iterations,int)==1)
strIni = "/Ini"
*endif
*endif


for i in range(Nsteps):
    t = ops.getTime() + Lincr
*if(PrintTime==1)
    print(f"(*IntvNum) {algorithmTypeStatic}{strIni} LF {t}")
*endif
    AnalOk = ops.analyze(1)
    if AnalOk != 0:
        break
    else:
        LoadCounter += 1.0
        committedSteps += 1

if AnalOk !=0:
    firstFail = 1
    AnalOk = 0
    Nk = 1
    returnToInitStepFlag = 0
*if(IntvData(Tolerance_relaxation,int)==1)
    InitialTolFlag = 1
    returnToInitTolFlag = 0
    ChangeToleranceFlag = 0
    SkipFirstLoopForTolRelaxFlag = 1
*endif
    while LoadCounter < Nsteps and AnalOk == 0:
        if (Nk == 2 and AnalOk == 0) or (Nk == 1 and AnalOk == 0):
            Nk = 1
            if returnToInitStepFlag:
                print("Back to initial Step")
                returnToInitStepFlag = 0
*if(IntvData(Tolerance_relaxation,int)==1)
            if returnToInitTolFlag:
                if not InitialTolFlag:
                    print("Back to initial error tolerance")
*format "%g"
                    TolStatic = TolStatic / *IntvData(Relaxation_factor,real)
                    InitialTolFlag = 1
*if(strcmp(IntvData(Convergence_criterion),"Norm_Unbalance")==0)
*format "%d"
                    ops.test("NormUnbalance", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Norm_Displacement_Increment")==0)
*format "%d"
                    ops.test("NormDispIncr", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Energy_Increment")==0)
*format "%d"
                    ops.test("EnergyIncr", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Unbalance")==0)
*format "%d"
                    ops.test("RelativeNormUnbalance", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Displacement_Increment")==0)
*format "%d"
                    ops.test("RelativeNormDispIncr", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Total_Relative_Norm_Displacement_Increment")==0)
*format "%d"
                    ops.test("RelativeTotalNormDispIncr", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Energy_Increment")==0)
*format "%d"
                    ops.test("RelativeEnergyIncr", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Fixed_Number_of_Iterations")==0)
*format "%d"
                    ops.test("FixedNumIter", *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*endif

            else:
                if InitialTolFlag and ChangeToleranceFlag and not SkipFirstLoopForTolRelaxFlag:
*format "%g"
                    print("Tolerance is multiplied by *IntvData(Relaxation_factor,real)")
*format "%g"
                    TolStatic **= *IntvData(Relaxation_factor,real)]
                    InitialTolFlag = 0
*if(strcmp(IntvData(Convergence_criterion),"Norm_Unbalance")==0)
*format "%d"
                    ops.test("NormUnbalance", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Norm_Displacement_Increment")==0)
*format "%d"
                    ops.test("NormDispIncr", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Energy_Increment")==0)
*format "%d"
                    ops.test("EnergyIncr", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Unbalance")==0)
*format "%d"
                    ops.test("RelativeNormUnbalance", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Norm_Displacement_Increment")==0)
*format "%d"
                    ops.test("RelativeNormDispIncr", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Total_Relative_Norm_Displacement_Increment")==0)
*format "%d"
                    ops.test("RelativeTotalNormDispIncr", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Relative_Energy_Increment")==0)
*format "%d"
                    ops.test("RelativeEnergyIncr", TolStatic, *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*elseif(strcmp(IntvData(Convergence_criterion),"Fixed_Number_of_Iterations")==0)
*format "%d"
                    ops.test("FixedNumIter", *IntvData(Max_Iterations_per_Step,int), *LoggingFlag)
*endif
            SkipFirstLoopForTolRelaxFlag = 0
*endif
            if firstFail == 0: # for the first time only, do not repeat previous failed step
                ops.integrator("LoadControl", Lincr) # reset to original increment
                t = ops.getTime() + Lincr
*if(PrintTime==1)
                print(f"(*IntvNum) {algorithmTypeStatic}{strIni} LF {t} ")
*endif
                AnalOk = ops.analyze(1) # zero for convergence
            else:
                AnalOk = 1
                firstFail = 0
            if AnalOk == 0:
                LoadCounter += 1.0 / Nk
                committedSteps += 1

        # substepping /2
        if (AnalOk !=0 and Nk==1) or (AnalOk==0 and Nk==4):
            Nk = 2; # reduce step size
            continueFlag = 1
            print("Initial step is divided by 2")
            LincrReduced = Lincr/ Nk
            ops.integrator("LoadControl", LincrReduced)
            for ik in range(Nk):
                if continueFlag==0:
                    break
                t = ops.getTime() + LincrReduced
*if(PrintTime==1)
                print(f"(*IntvNum) {algorithmTypeStatic}{strIni} LF {t}")
*endif
                AnalOk = ops.analyze(1); # zero for convergence
                if AnalOk == 0:
                    LoadCounter += 1.0 / Nk
                    committedSteps += 1
                else:
                    continueFlag = 0

            if AnalOk == 0:
                returnToInitStepFlag = 1

*if(IntvData(Tolerance_relaxation,int)==1)
*if(strcmp(IntvData(Tolerance_relaxation_after_failed_substepping_of),"/2")==0)
        if AnalOk != 0:
            if InitialTolFlag:
                Nk = 1 # back to initial step - tolerance relaxation
                AnalOk = 0
                returnToInitStepFlag = 1
                ChangeToleranceFlag = 1
                returnToInitTolFlag = 0

        else:
            if not InitialTolFlag:
                Nk = 1
                returnToInitTolFlag = 1
*endif
*endif
        # substepping /4
        if (AnalOk !=0 and Nk==2) or (AnalOk==0 and Nk==8):
            Nk = 4 # reduce step size
            continueFlag = 1
            print("Initial step is divided by 4")
            LincrReduced = Lincr / Nk
            ops.integrator("LoadControl", LincrReduced)
            for ik in range(Nk):
                if continueFlag==0:
                    break
                t = ops.getTime() + LincrReduced
*if(PrintTime==1)
                print("(*IntvNum) {algorithmTypeStatic}{strIni} LF {t} ")
*endif
                AnalOk = ops.analyze(1) # zero for convergence
                if AnalOk == 0:
                    LoadCounter += 1.0 / Nk
                    committedSteps += 1
                else:
                    continueFlag = 0
            if AnalOk == 0:
                returnToInitStepFlag = 1
        # end if Nk=4
*if(IntvData(Tolerance_relaxation,int)==1)
*if(strcmp(IntvData(Tolerance_relaxation_after_failed_substepping_of),"/4")==0)
        if AnalOk != 0:
            if InitialTolFlag:
                Nk = 1 # back to initial step - tolerance relaxation
                AnalOk = 0
                returnToInitStepFlag = 1
                ChangeToleranceFlag = 1
                returnToInitTolFlag = 0
        else:
            if not InitialTolFlag:
                Nk = 1
                returnToInitTolFlag = 1
*endif
*endif
        # substepping /8
        if (AnalOk !=0 and Nk==4) or (Nk == 16 and AnalOk == 0):
            Nk = 8 # reduce step size
            continueFlag = 1
            print("Initial step is divided by 8")
            LincrReduced = Lincr / Nk
            ops.integrator("LoadControl", LincrReduced)
            for ik in range(Nk):
                if continueFlag==0:
                    break
                t = ops.getTime() + LincrReduced
*if(PrintTime==1)
                print(f"(*IntvNum) {algorithmTypeStatic}{strIni} LF {t} ")
*endif
                AnalOk = ops.analyze(1) # zero for convergence
                if AnalOk == 0:
                    LoadCounter += 1.0 / Nk
                    committedSteps += 1
                else:
                    continueFlag = 0
            if AnalOk == 0:
                returnToInitStepFlag = 1
        # end if Nk=8
*if(IntvData(Tolerance_relaxation,int)==1)
*if(strcmp(IntvData(Tolerance_relaxation_after_failed_substepping_of),"/8")==0)
        if AnalOk != 0:
            if InitialTolFlag:
                Nk = 1 # back to initial step - tolerance relaxation
                AnalOk = 0
                returnToInitStepFlag = 1
                ChangeToleranceFlag = 1
                returnToInitTolFlag = 0

        else:
            if not InitialTolFlag:
                Nk = 1
                returnToInitTolFlag = 1
*endif
*endif
        # substepping /16
        if Nk == 8 and AnalOk!=0:
            Nk = 16 # reduce step size
            continueFlag = 1
            print("Initial step is divided by 16")
            LincrReduced = Lincr / Nk
            ops.integrator("LoadControl", LincrReduced)
            for ik in range(Nk):
                if continueFlag==0:
                    break
                t = ops.getTime() + LincrReduced
*if(PrintTime==1)
                print(f"(*IntvNum) {algorithmTypeStatic}{strIni} LF {t}")
*endif
                AnalOk = ops.analyze(1) # zero for convergence
                if AnalOk == 0:
                    LoadCounter += 1.0 / Nk
                    committedSteps += 1
                else:
                    continueFlag = 0

            if AnalOk == 0:
                returnToInitStepFlag = 1
        # end if Nk=16
*if(IntvData(Tolerance_relaxation,int)==1)
*if(strcmp(IntvData(Tolerance_relaxation_after_failed_substepping_of),"/16")==0)
        if AnalOk != 0:
            if InitialTolFlag:
                Nk = 1 # back to initial step - tolerance relaxation
                AnalOk = 0
                returnToInitStepFlag = 1
                ChangeToleranceFlag = 1
                returnToInitTolFlag = 0

        else:
            if not InitialTolFlag:
                Nk = 1
                returnToInitTolFlag = 1
*endif
*endif
# end while loop
# end if AnalOk

if AnalOk == 0:
    print("Analysis completed SUCCESSFULLY")
    print("Analysis completed SUCCESSFULLY", file=open(f"{__file__[:-3]}.log", "a"))
    print(f"Committed steps : {committedSteps}")
    print(f"Committed steps : {committedSteps}", file=open(f"{__file__[:-3]}.log", "a"))
else:
    print("Analysis FAILED")
    print("Analysis FAILED", file=open(f"{__file__[:-3]}.log", "a"))
    print(f"Committed steps : {committedSteps}")
    print(f"Committed steps : {committedSteps}", file=open(f"{__file__[:-3]}.log", "a"))