# Stock Report
Generate and show a stock report for the last 5 business days of brazilian stock market (Bovespa).

## Configuration
 Open file **config.json** and change the following fields:
 
 **key**
 
 Sign up on Alpha Vantage and get the API key: https://www.alphavantage.co/support/#api-key.
 
 
**stocks**

The stock symbol or a list of stock symbols.

## Configuration Example
ex:
```JSON
{
  "key": "YOUR_KEY",
  "stocks": ["PETR4","VALE3"]
}
```
This configuration should set parameters for generating a report for Petróleo Brasileiro S.A (Petrobras) and Vale S.A.


## Usage

```console
ruby stock_report.rb
```

## Tests

```console
cd test
ruby stock_report_test.rb
```
