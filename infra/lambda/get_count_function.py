import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloud-resume-views') 

def lambda_handler(event, context):
    
    # Get the item from the table
    response = table.get_item(
        Key={
            'page_id': 'resume' 
        }
    )
    
    view_count = response.get('Item', {}).get('views', 0)
    
    # Return the count
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'GET'
        },
        'body': json.dumps({'views': int(view_count)})
    }