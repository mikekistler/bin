#!/usr/bin/env python3

# This python script reads a markdown file and replaces all the links in the form
# "<xref:Microsoft.AspNetCore.Http.EndpointSummaryAttribute>"
# with a link in this form:
# "[[EndpointSummary]](xref:Microsoft.AspNetCore.Http.EndpointSummaryAttribute)"

# The input is passed as stdin and the output is printed to stdout

import re
import sys

def replace_links(text):
    pattern = r'<xref:((Microsoft|System)\.[^>]*)>'
    # The link text should be just the last segment of the xref link (separated by '.')
    # and if the last segment ends in "Attribute", then drop the "Attribute" part
    # but wrap the rest in brackets
    def format_link(match):
        link_text = match.group(1).split('.')[-1]
        if link_text.endswith("Attribute"):
            link_text = f'[{link_text[:-9]}]'
        if link_text.endswith("%2A"):
            link_text = link_text[:-3]
        if link_text.endswith("%601"):
            link_text = link_text[:-4]
        return f'[`{link_text}`](xref:{match.group(1)})'

    return re.sub(pattern, format_link, text)

if __name__ == "__main__":
    input_text = sys.stdin.read()
    output_text = replace_links(input_text)
    print(output_text)
