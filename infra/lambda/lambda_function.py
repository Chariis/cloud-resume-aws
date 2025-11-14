# infra/lambda/lambda_function.py

import json
import boto3

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')

# This table name MUST match the 'table_name' variable in your variables.tf
table = dynamodb.Table('cloud-resume-views') 

def lambda_handler(event, context):
    
    # Atomically increment the 'views' counter
    response = table.update_item(
        Key={
            # This 'page_id' MUST match the item your pipeline seeds
            'page_id': 'resume' 
        },
        
        # Use a placeholder #v for the reserved keyword 'views'
        UpdateExpression='SET #v = #v + :inc',
        
        # Define what the placeholder #v means
        ExpressionAttributeNames={
            '#v': 'views'
        },
        
        # Define what the placeholder :inc means
        ExpressionAttributeValues={
            ':inc': 1
        },
        
        ReturnValues='UPDATED_NEW'
    )
    
    # Get the new view count from the response
    new_view_count = response['Attributes']['views']
    
    # Format the response to be sent back to the website
    # The headers are CRITICAL for Cross-Origin Resource Sharing (CORS)
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*', # Allows any domain to call this
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'GET'
        },
        'body': json.dumps({'views': int(new_view_count)})
    }