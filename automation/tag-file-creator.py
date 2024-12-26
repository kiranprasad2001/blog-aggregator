import json
import os

def create_tag_files(data):
    tag_data = {}

    for item in data:
        title = item['title']
        link = item['link']
        for tag in item['tags']:
            # Store the original tag with spaces for the title
            original_tag = tag  
            # Replace spaces with hyphens for the filename
            tag = tag.replace(" ", "-")  
            if tag not in tag_data:
                tag_data[tag] = {'count': 0, 'links': [], 'original_tag': original_tag}
            tag_data[tag]['count'] += 1
            tag_data[tag]['links'].append({'title': title, 'link': link})

    # Go up two levels to reach the project root
    project_root = os.path.abspath(os.path.join(os.getcwd(), "..", ".."))  
    # Include 'blog-aggregator' in the path
    tag_dir = os.path.join(project_root, 'blog-aggregator', 'tags')  
    os.makedirs(tag_dir, exist_ok=True)  # Create the 'tags' directory if it doesn't exist

    for tag, data in tag_data.items():
        filename = os.path.join(tag_dir, f"{tag}.md")
        with open(filename, 'w') as f:
            f.write("---\n")
            f.write(f"layout: tag\n")
            # Use the original tag with spaces for the title
            f.write(f"title: {data['original_tag']}\n") 
            f.write(f"count: {data['count']}\n")  # Add the count of the tag
            f.write("---\n\n")

            for item in data['links']:
                f.write(f"- [{item['title']}]({item['link']})\n")

if __name__ == "__main__":
    # Go up three levels to reach the project root
    project_root = os.path.abspath(os.path.join(os.getcwd(), "..", ".."))
    # Include 'blog-aggregator' in the path
    data_file = os.path.join(project_root, 'blog-aggregator', '_data', 'posts.json')
    with open(data_file, 'r') as f:
        data = json.load(f)
    create_tag_files(data)