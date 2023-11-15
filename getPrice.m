%This function performs the API query that actually returns the stock price
%and prints it to console

function getPrice(platform)
    
    %We ask the user for stock tickers or stock names and this invoked
    %method returns a list of the tickers requested along with a formatted
    %string to be used in the API request
    [tickers, ticker_list] = platform.getTickers(platform);
   
    %Checks if ticker input is empty
    if(isempty(ticker_list))
        fprintf("\nNo Input Provided! Returning back to welcome screen\n");
        fprintf("\n");
        return;
    end

    %We craft the API Request into a string by concatenating the stock
    %tickers
    req = sprintf("/v2/stocks/trades/latest?currency=USD&symbols=%s", tickers);
    
    %Try catch used to show any errors to user if they occur
    try

        %We make the API request adding the baseURL to the request
        %line of code inspired from
        %https://forum.alpaca.markets/t/anyone-using-matlab-with-api-v2/587/4
        response = webread(platform.market_url + req, platform.header_auth);
        
        %We show the requested prices
        fprintf("\nRequested Prices:\n");

        %Prints a formatted console output showing stock ticker and it's
        %price
        for i = 1:length(ticker_list)
            fprintf("%s: $%.2f USD\n", ticker_list(i), response.trades.(ticker_list(i)).p);
        end

    catch ME
        %If there is an error with the API an error message is displayed (in red text)
        fprintf(2, '\nError Message: \n%s\n', ME.message);   
    end
    
    %Print a blank line for formatting
    fprintf("\n");

end