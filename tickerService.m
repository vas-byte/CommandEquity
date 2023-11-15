%This class is used to store the URLs and authentication headers of the 
%REST API used, in addition this class includes methods which are used to 
%verify that a stock ticker is valid or lookup a stock ticker from the name
%of a company and return formatted strings for the API request

%This version also removes crypto assets from the list of retrieved assets
%by the API since it is not covered by the market data API


classdef tickerService
    
    properties
        api_equities %List of company names
        api_tickers %List of company stock tickers
        market_url %Base URL for requesting stock prices
        header_auth %Variable to store API key and secret for GET request
    end    

    methods(Static)
        
        %Constructor (called when class initialized)
        function class = tickerService()
            market_url = "https://data.alpaca.markets";

            %Base URL for getting a list of stocks the API can request prices for
            assets_url = "https://paper-api.alpaca.markets"; 

            %Configure API Authentication (Header of GET request)
            header_auth = weboptions('HeaderFields',{'APCA-API-KEY-ID','API KEY GOES HERE';...
            'APCA-API-SECRET-KEY','API SECRET GOES HERE'},"Timeout",30);
           
            %We attempt to request a list of all the stocks the API can get
            %prices for
            try

                %if successful we store the result in a variable response
                %LINE INSPIRED BY https://forum.alpaca.markets/t/anyone-using-matlab-with-api-v2/587/4
                response = webread(assets_url + "/v2/assets?status=active", header_auth);

            catch ERROR

                %if unsuccessful the application is terminated and an error
                %is shown to the user
                  throw(ERROR);

            end
            
            

            %We create two vectors to store the name and ticker of the
            %companies the API can ask prices for
            api_equities = [];
            api_tickers = [];

            %Iterate over response structure with pricable stocks
            for i = 1:length(response)

                %Assign a variable to the current struct in the cell array
                var = response(i,1);

                %Check that the tradeable stock is not traded in over the
                %counter markets as the free API cannot retrieve prices for
                %these stocks - according to API documentation 
                %https://alpaca.markets/docs/api-references/market-data-api/stock-pricing-data/
                %Also we exclude crypto assets since market data API cannot
                %be used to query the exchange rate of crypto currencies
                if(string(var{1}.exchange) ~= "OTC" || string(var{1}.class) ~= "crypto")

                    %If stock not traded over the counter, we add it's
                    %name and ticker to the vectors below such that the
                    %order is the same for both (same index between two vectors)
                    api_equities = [api_equities string(var{1}.name)];
                    api_tickers = [api_tickers string(var{1}.symbol)];
                end
            end
            
            %We define the properties of the class from the declared
            %variables above
            class.api_equities = api_equities;
            class.api_tickers = api_tickers;
            class.market_url = market_url;
            class.header_auth = header_auth;

        end

        %This method is invoked to ask the user for tickers and format a
        %string to be used in the GET request to the API
        function [tickers, ticker_list] = getTickers(this)
            
            %Variable containing formatted string to be used in API request
            tickers = "";

            %Vector containing the actual tickers requested
            ticker_list = [];
            
            %Create loop that requires termination by user
            while 1

                %Prompt user for ticker or company name input
                ticker = input("Enter a ticker or Company Name (type -1 to finish): ", "s");
                

        
                %Check if user has finished entering tickers
                if ticker == "-1"
                    
                    %Terminate while loop and return variables "ticker" 
                    % and "ticker_list"       
                    break;
                
                %We check if this is the user's first ticker input (for formatting)
                elseif strlength(tickers) == 0

                    %We check if the user has inputted a valid ticker or
                    %company name - if not the function returns ""
                    ticker = this.checkTicker(ticker, this);
              
                    %check if validation function was unable to find
                    %a valid ticker
                    if ticker == ""

                        %If true we repeat the while loop prompting the
                        %user for a new input
                        continue;

                    end
                    
                    %We format the string to be used in the API request 
                    %to contain the ticker of the stock requested,
                    %the special formatting in this case is that the first 
                    %stock ticker cannot have a comma before it,
                    %(ie ",APPL" is an invalid input to the API it must be
                    % "APPL" if it is the first ticker)
                    tickers = tickers + sprintf("%s", ticker);
                    
                    %We append the ticker to a vector containing all the
                    %tickers requested
                    ticker_list = [ticker_list, string(ticker)];
                
                %Otherwise the user has entered another ticker    
                else 

                    %Check if ticker is valid or company name has
                    %corresponding ticker
                    ticker = this.checkTicker(ticker, this);

                    %check if validation function was unable to find
                    %a valid ticker
                    if ticker == ""
                        
                        %if not we re-run the while loop prompting for new
                        %user input
                        continue;
                    end
                    
                    %We format the string to be used in the API request 
                    %to contain the ticker of the stock requested,
                    %in this case the ticker is added to a string of
                    %existing tickers that are comma separated as specified
                    %by the API (e.g. "AAPL,MSFT")
                    tickers = tickers + sprintf(",%s", ticker);

                    %We append the ticker to a vector containing all the
                    %tickers requested
                    ticker_list = [ticker_list, string(ticker)];

                end
        
            end

        end


        %Method invoked to validate ticker exists or lookup stock ticker
        %from company name
        function [ticker] = checkTicker(input_ticker, this)
            
            %Iterate over list of tickers to check if input string contains
            %a ticker and is valid
            for i = 1:length(this.api_tickers)
                
                %This if statement checks each ticker in the vector against
                %the user input
                if strcmpi(this.api_tickers(i), input_ticker)

                    %If true the ticker is returned back to the
                    %getTickers() function
                    ticker = string(upper(input_ticker));
                    return;

                end

            end

            %Othereise the user most likely entered a company name which
            %needs to be represented as a ticker, this prompt shows
            % "Did you mean" followed by ticker suggestions            
            fprintf("\nDid you mean:\n");
            
            %Store a vector containing indexes where stock names match the
            %user input in the "api_equities" vector
            indexes = [];

            %Iterate over "api_equities" vector
            for i = 1:length(this.api_equities)
                
                %Check if string within each element of vector contains the 
                %user input 
                if strfind(lower(this.api_equities(i)), lower(input_ticker)) > 0
                    
                    %Append index of match within "api_equities" vector to
                    %"indexes" vector 
                    indexes = [indexes i];
                    
                    %Show potential suggestion to user
                    fprintf("%d. %s : %s\n",length(indexes), ...
                        this.api_equities(i), this.api_tickers(i));

                end

            end
            
            %If there is no match for stock name, we show that to the user
            %and return an empty string ("") to the getTickers() function
            if isempty(indexes)
                fprintf("No Options Found\n\n");
                ticker = "";
                return;
            end
            
            while 1
                %Otherwise we prompt the user to enter a number corresponding
                %to the company name they couldn't remember the ticker for
                tickeropt = input("Option: ", "s");

                %Convert to int from string (makes error handling easier)
                tickeropt = str2num(tickeropt);
                
                if(isempty(tickeropt))
                    %Show user message saying input is valid in console
                    fprintf(2, "\nPlease Enter a Number\n");
        
                    %Starts new iteration of while loop - reprompts for user input
                    continue;
                end
                
                %If statement used within while loop to validate user input 
                % (ie: ensure the option entered corresponds to an option shown)
                if(tickeropt < 1 || tickeropt > length(indexes))
                    
                    %If invalid, print the statement below and re-ask for input
                    fprintf(2, "\nPlease Input a valid option\n");
        
                else
        
                    %If valid input, break out of the while loop
                    break;
        
                end
        
            end
                    
            %Print new line for formatting
            fprintf("\n");

            %Return stock ticker for equity name by using the index
            %provided in the "indexes" vector to get the ticker at that index
            %within the "api_tickers" vector, the option the user enters is
            %the index to the indexes vector
            ticker = this.api_tickers(indexes(tickeropt));

        end


    end
end