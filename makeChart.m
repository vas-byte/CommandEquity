%This function is called to make the API request for the stock prices at
%certain time intervals and produce the data plot

function makeChart(platform)
    
    %Create instance of class chartLengthServiceService which is used to
    %determine the time incremenths for which stock prices are to
    %be queried in order to produce a chart over a certain length
    %of time from the current date
    increment_obj = chartLengthService();    
    
    %We calculate the time increment between requests
    increment = increment_obj.calculateIncrement(increment_obj);

    %Get list of tickers from user by invoking method
    [~, ticker_list] = platform.getTickers(platform);

    %Checks if ticker input is empty
    if(isempty(ticker_list))
        fprintf("\nNo Input Provided! Returning back to welcome screen\n");
        fprintf("\n");
        return;
    end

    %We get a maximum sample of 200 data points per ticker over any data period,
    %this counter is used to update the progress bar as the API requests are made 
    counter = 0;

    %"prices" and "dates" are cell arrays containing the historical stock 
    %price data for multiple tickers
    prices = {};
    dates = {};
    
    %Creates a loading bar
    %line of code inspired from https://au.mathworks.com/help/matlab/ref/waitbar.html
    prog_bar = waitbar(0,'Please wait...');
    
    %Get the current date and time as RFC3389 format (as outlined in the API docs)
    %line of code inspired from https://au.mathworks.com/matlabcentral/answers/613776-converting-datetime-rfc3339-to-matlab-datetime-format
    today = datetime('now','timeZone', 'UTC', 'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSS''Z''') - minutes(10);

    %Used to show errors with API
    try
        %Iterate over number of tickers that a chart has been requested for
        for index = 1:length(ticker_list)
            
            %Create a vector with the prices and dates of the current
            %ticker (ie row of the "prices" and "dates" matricies)
            prices_row = [];
            dates_row = [];

            %Incremented time that stock requests are made at
            time_increment = today;
            
            %Current ticker in the list of tickers charts are to be
            %produced for
            ticker = ticker_list(index);
    
            %Iterate 200 times to get a maximum sample of 200 data points
            for request = 1:200
                   
                    %Subtract the time increment from the date time object,
                    %on the first run we subtract the time increment from
                    %"now" - it should also be noted that "now" is 10
                    %minutes late as the API using this request cannot
                    %retrieve the latest price and is slightly delayed

                    %line of code inspired from:
                    %https://au.mathworks.com/help/matlab/matlab_prog/compute-elapsed-time.html
                    time_increment = time_increment - minutes(increment);

                    %We format the datetime object as a string
                    time_string = string(time_increment);
                    
                    %We concatenate the time in RFC3389 format to the 
                    %string used in the API request 
                    req = sprintf("/v2/stocks/%s/trades?currency=USD&start=%s&limit=1", ticker, time_string);
                    
                    %We request the price of the stock at the specified
                    %time
                    %line of code inspired from
                    %https://forum.alpaca.markets/t/anyone-using-matlab-with-api-v2/587/4
                    response = webread(platform.market_url + req, platform.header_auth);
                    
                    %We check that price data exists at the queried time
                    if(~isempty(response.trades))
                        
                        %If price data exists at the queried time we
                        %prepend it to the "prices_row" vector and prepend
                        %the date to the "dates_row" vector
                        prices_row = [response.trades(1).p prices_row];
                        dates_row = [datetime(time_increment, 'TimeZone','Australia/Adelaide') dates_row];  
                   
                    end
                    
                    %Increment the counter by 1
                    counter = counter + 1;

                    %Update the progress bar
                    %line of code inspired from https://au.mathworks.com/help/matlab/ref/waitbar.html
                    waitbar(counter/(length(ticker_list)*200), prog_bar, "Loading your Data");
                    
    
            end
            
            %Append the prices and dates for each ticker to "prices" and
            %"dates" cell arrays
            %code inspired by https://au.mathworks.com/matlabcentral/answers/222898-how-to-append-a-new-element-to-a-cell-object-a
            prices{end + 1} =  prices_row;
            dates{end + 1} =  dates_row;
    
        end
        
        %Close progress bar as data has been collected
        %line of code inspired from https://au.mathworks.com/help/matlab/ref/waitbar.html
        close(prog_bar);
        
        %We get the number of elements from the "prices" cell array 
        % (same as nubmer of rows in "dates" cell array)
        [~, cols] = size(prices);
        
        %Iterate over each row in "prices" and "dates" cell arrays
        for i = 1:cols
            
            %We plot each row (representing each ticker) on the same set of
            %axes for comparison
            plot(dates{i}, prices{i}, 'DisplayName', ticker_list(i));
            hold on

        end
    
        %Used to show legend
        legend

        %print newline for formatting
        fprintf("\n");

    %Called when an error is encountered
    catch ME
        
        %Closes loading bar
        try
            %line of code inspired from https://au.mathworks.com/help/matlab/ref/waitbar.html
            close(prog_bar);
        catch
        
        end

        %Shows user error in red text
        fprintf(2, "\nError Message: \n%s\n", ME.message);

        %Print a new line
        fprintf("\n");
    end
    
end