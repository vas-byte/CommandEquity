%This class is primarily used to determine the time interval for which
%stock prices are to be requested by the API


classdef chartLengthService
    properties
        
        %Dictionary which maps how many days in each month
        month_days = dictionary("January", 31, "February", 28, "March", 31, ...
            "April", 30, "May", 31, "June", 30,"July", 31,"August", 30, ...
            "September", 31, "October", 30, "November", 30, "December", 31);
        
        %Variabel whicb stores how many time periods in the denomination of
        %time elected
        period

        %How time is measured (ie days, months, years)
        type
       
    end

    methods(Static)
        
        %This method asks the time period for which the stock chart is to
        %be produced
        function lengthPrompt = chartLengthService()
            
            %forces user to enter valid option
            while 1
                
                %Display chart length options to user
                fprintf("\nSelect time period\n")
                fprintf("\n1. 1 Day\n");
                fprintf("2. 5 Days\n");
                fprintf("3. 1 Month\n");
                fprintf("4. 6 Months\n");
                fprintf("5. 1 Year\n");
                fprintf("6. 5 Years\n\n");
    
                %Prompt user for numertical input regarding which chart length
                %input
                option = input("option: ", "s");
            
                %Convert to int from string (makes error handling easier)
                option = str2num(option);
                
                if(isempty(option))
                    %Show user message saying input is valid in console
                    fprintf(2, "\nPlease Input A  Number ");
        
                    %Starts new iteration of while loop - reprompts for user input
                    continue;
                end

                %Check user input
                switch(option)
                    case 1 
                        %Set period propertiy of class instance to 1 unit (ie 1 day)
                        lengthPrompt.period = 1;
    
                        %Set time measurement property of class instance to
                        %days
                        lengthPrompt.type = "days";

                        %Ends infinite loop for validating user input
                        break;

                    case 2
                        lengthPrompt.period = 5;
                        lengthPrompt.type = "days";    
                        break;

                    case 3
                        lengthPrompt.period = 1;
                        lengthPrompt.type = "months";   
                        break;

                    case 4
                        %Set period propertiy of class instance to 6 unis (ie 6 months)
                        lengthPrompt.period = 6;
    
                        %Set time measurement property of class instance to
                        %months
                        lengthPrompt.type = "months";

                        %Ends infinite loop for validating user input
                        break;
    
                    case 5
                        lengthPrompt.period = 1;
                        lengthPrompt.type = "years";
                        
                        break;

                    case 6
                        lengthPrompt.period = 5;
                        lengthPrompt.type = "years";
                        
                        break;
                    
                    otherwise
                        %called if user enters invalid option
                        fprintf(2, "\nPlease Enter A Valid Option Between 1 and 6 ");
                end
            end
    
        end

        %Method which calculates the time increment based off chart length,
        %this method is always invoked after chartLength so period and type
        %properties are initialized
        function [increment] = calculateIncrement(this)
    
            %Determine type of time measurement within instance of class
            switch(this.type)
        
                case "years"

                    %Create a vector with number of days for each year
                    days = [];
            
                    %Iterate over number of years
                    for i = 1:this.period

                        %Start from current year and subtract 1 year with
                        %each iteration
                        now = datetime('now') - (i - 1);

                        %We store the year of the datetime object "now"
                        [y,~,~] = ymd(now);
                        
                        %Check if the year is a leap year
                        if mod(y,4) == 0
                            
                            %If leap year we append 366 to "days" vector
                            days = [days 366];
                        else

                             %If not leap year we append 365 to "days" vector
                            days = [days 365];
                        end
                     
                    end
                    
                    %get total number of days in time period
                    sum_days = sum(days);
            
                    %Convert time increment to minutes and return it's
                    %value
                    increment = sum_days * 24 * 60 / 200;
        
                case "months"

                    %Create a vector for the number of days in the queried
                    %months
                    days = [];
            
                    %Iterate over the number of months
                    for i = 1:this.period

                        %Start from current month and incrementally
                        %subtract one month untill iterating over the
                        %number of periods
                        now = datetime('now') - (i - 1);

                        %get the month as a string - key value store in
                        %dict
                        monthstr = month(now,'name');

                        %query dict for number of days in that month and
                        %append it to "days" vector
                        days = [days this.month_days(monthstr)];
                    end
            
                    %Get the total number of days for the time period
                    sum_days = sum(days);
            
                    %Convert time increment to minutes and return it's
                    %value
                    increment = sum_days * 24 * 60 / 200;
        
                case "days"

                    %Convert time increment to minutes and return it's
                    %value
                    increment = this.period * 24 * 60 / 200;
        
            end
        end
    end
end