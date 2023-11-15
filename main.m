%Driver script for entire program

%The final iteration of the application introduces error handling around
%the API requests in case of predominantly network related issues. Error
%handling may also be raised if the API rate limit of 200 requests per
%minute is exceeded.

%In addition, improved language of error handling and main menu options
%(specifically I updated option 1 to state it's purpose more clearly)

%Create instance of class tickerService (variable platform is an object)
platform = tickerService();

%Create Infinite Loop
while 1

    %Display options to user regarding whether to query stock price, produce chart or
    %exit the application
    fprintf("Choose from the decisions below:\n\n")
    fprintf("1. Query latest stock prices\n");
    fprintf("2. Generate a chart\n");
    fprintf("3. Exit\n\n");

    %Take user input relating to options above
    option = input("option: ", "s");

    %Convert to integer (makes error handling easier)
    option = str2num(option);

    %if the input is not a number, option will be empty and the user will 
    %be notified of entering an invalid input
    if(isempty(option))
        
        %Show user message saying input is valid in console
        fprintf(2, "\nPlease Enter a Number\n");

        %Starts new iteration of while loop - reprompts for user input
        continue;

    end 

    %Check user input to direct the program
    switch(option)
        
        case 1
             %Calls function that queries the price of stocks inputted by
             %user
             getPrice(platform);

        case 2
             %Calls function to make chart and display it to user
             makeChart(platform);

        case 3
            %Exits by the program by clearing the workspace, clearing the
            %command window and breaking the while loop
            clc;
            clear;
            break;

        otherwise
            %This option is called if the input number is not between 1 and
            %3 indicating an invalid input, this is displayed to the user
            %and they are prompted for another input (while loop repeats)
            fprintf(2, "\nInvalid Option, please enter a number between 1 and 3\n");
    end
    
end


