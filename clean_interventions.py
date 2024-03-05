import pandas
import csv
import re

def extract_digit_sequences(s):
    #find all sequences of digits
    digit_sequences = re.findall(r'\d+', s)
    
    #check if '-' is present and ensure single numbers are duplicated
    if '-' in s and len(digit_sequences) == 2:
        #if there are two numbers separated by '-', just convert them to integers
        return [int(num) for num in digit_sequences]
    else:
        #if there's only one number
        return ['0', int(digit_sequences[0])]
    

if __name__ == '__main__':

    #read xlsx file into pandas dataframe
    df = pandas.read_excel('srcsc-2024-interventions.xlsx', sheet_name='Interventions', header=16)
    #export pandas dataframe to csv file
    df.to_csv('Interventions.csv', index=False)

    with open('Interventions.csv', mode='r') as csv_file:
        interventions = csv.reader(csv_file)
        data = [row for row in interventions]
        col_names = data[0] + ['Lower Mortality Rate Impact', 'Higher Mortality Rate Impact', 'Lower Cost Per Capita', 'Higher Cost Per Capita']
        data = data[1:]
        for j in range(len(data)):
            for i in range(len(data[j])):
                data[j][i] = data[j][i].strip('" ')
            data[j] += extract_digit_sequences(data[j][2]) + extract_digit_sequences(data[j][3])

    with open('intervention_cleaned.csv', mode='w', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(col_names)

        for row in data:
            writer.writerow(row)

        











