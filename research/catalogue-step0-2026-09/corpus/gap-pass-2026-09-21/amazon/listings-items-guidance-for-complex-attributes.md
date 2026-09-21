---
updatedAt: 2026-09-09T22:46:17.000Z
---

Fetch the complete documentation index at: https://developer-docs.amazon/sp-api/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Guidance for Complex Attributes

Guidance regarding footwear sizes and apparel sizes.

Required or conditionally required values depend on the attributes selected for <span class="notranslate">**Target Gender**</span> and <span class="notranslate">**Age Range Description**</span> as well as the <span class="notranslate">**Product Type**</span>.

> 📘 Note
>
> Apparel size-specific attributes are catalog-wide rules that apply to all listings submissions, whether submitted through the SP-API or Seller Central. To learn more about these attributes and their values, refer to the [Apparel size standards](https://sellercentral.amazon.com/help/hub/reference/external/GZXM4PHSSX9YUT87?locale=en-US) guide in Seller Central.

## Footwear Sizes

<table>
    <tr>
        <th>Attribute</th>
        <th>Required?</th>
        <th>Definition</th>
        <th>Examples</th>
    </tr>
    <tr>
        <td><strong>Target Gender</strong></td>
        <td>Required</td>
        <td>The gender for which the product is intended.</td>
        <td>Male, Female, Unisex (Note: if Unisex is selected, the vendor needs to provide size values for both male and female)</td>
    </tr>
    <tr>
        <td><strong>Age Range Description</strong></td>
        <td>Required</td>
        <td>The age for which the product is intended.</td>
        <td>Adult, Kid, Baby</td>
    </tr>
    <tr>
        <td><strong>Footwear Size System</strong></td>
        <td>Required</td>
        <td>The footwear size system displays Amazon store-specific shoe sizes to customers onsite.</td>
        <td>UK Footwear Size System</td>
    </tr>
    <tr>
        <td><strong>Shoe Size Age Group</strong></td>
        <td>Required</td>
        <td>The age group for which the shoe size is intended.<br/><b>Note:</b> Shoe Size values depends on what is selected for Age Group. For example, selecting “Infant” means you can’t input size 11, 12, 13, UK.</td>
        <td>Infant, Toddler, Little Kid – we add suffix ‘Child’ to the shoe size value<br/>Big Kid, Adult – we do not add suffix ‘Child’ to the shoe size value.</td>
    </tr>
    <tr>
        <td><strong>Shoe Size Gender</strong></td>
        <td>Required for Target Gender = Unisex and Shoe Size Age Group = Adult.</td>
        <td>The gender for which the shoe size is intended.</td>
        <td>Women, Men</td>
    </tr>
    <tr>
        <td><strong>Shoe Size Class</strong></td>
        <td>Required</td>
        <td>
            Class of shoe size representation<br/>
            <b>Note:</b> Age and Age Range size classes are only allowed for Shoe Size Age Group = Infant OR Toddler OR Little Kid
        </td>
        <td>
            <strong>Numeric</strong> – displays values such as 7 UK, 7.5 UK, 8 UK<br/>
            <strong>Numeric Range</strong> – displays values such as 7/8 UK, 8.5/9 UK<br/>
            <strong>Alpha</strong> – displays values such as One Size, XX-Small, Medium, X-Large<br/>
            <strong>Alpha Range</strong> – displays values such as Small/Medium, Medium/Large<br/>
            <strong>Age</strong> – displays values such as 6 Months (up to 24 Months), 2.5 Years (up to five Years)<br/>
            <strong>Age Range</strong> – displays values such as 6-12 Months (up to 24 Months), 2-3 Years (up to five Years)
        </td>
    </tr>
    <tr>
        <td><strong>Shoe Size Width</strong></td>
        <td>Required</td>
        <td>The width of the shoe.</td>
        <td>Medium, Narrow, Wide, X-Narrow, X-Wide, XX-Narrow, XX-Wide, 3X-Narrow, 3X-Wide</td>
    </tr>
    <tr>
        <td><strong>Shoe Size</strong></td>
        <td>Required</td>
        <td>The size of the shoe.</td>
        <td>
            The values displayed are dependent on the value selected in <strong>Age Group and Shoe Size Class</strong>, for example, 8, 8.5, Small, 6 Months.<br/>
            If Numeric was selected in Shoe Size Class, then only numeric values such as 7, 7.5, 8 are displayed in Shoe Size.<br/>
            If “Infant” was selected for Age Group, then Shoes Size options are limited to a select list of infant size values.
        </td>
    </tr>
    <tr>
        <td><strong>Shoe Size To Range (If Range)</strong></td>
        <td>Required for Shoe Size Class =  Numeric Range OR Alpha Range OR Age Range</td>
        <td>Ending shoe range value. This is concatenated with the previous Shoe Size selection to build a range.</td>
        <td>
            The values displayed are <strong>dependent on the value selected in Shoe Size Class</strong>, for example, 8.5, 9, Medium, 12 Months.
        </td>
    </tr>
    <tr>
        <td><strong>For Adult Unisex products</strong></td>
        <td>Required if Target Gender = Unisex, Shoe Size Age Group = Adult and Shoe Size Class = Numeric, OR Numeric Range</td>
        <td>Opposite Gender values for the preceding information.</td>
        <td>Required to generate customer facing shoe sizes such as 7 UK Men/ 6 UK Women</td>
    </tr>
</table>

## Apparel Sizes

The attribute name prefix `Apparel Size` depends on the product type, for example `Shirt Size` for `SHIRT PT`, `Bottoms Size` for `PANTS`, `SHORTS` and `OVERALLS`.

<table>
    <tr>
        <th>Attribute</th>
        <th>Required?</th>
        <th>Examples</th>
        <th>Notes</th>
    </tr>
    <tr>
        <td><strong>Apparel Size System</strong></td>
        <td>Required. The apparel size system is used to display Amazon store-specific apparel sizes to customers on-site.</td>
        <td>UK</td>
        <td>Apparel Size System is associated with the selected Amazon store.</td>
    </tr>
    <tr>
        <td><strong>Apparel Size Class</strong></td>
        <td>Required. Select the class of apparel size representation.</td>
        <td>Age, Alpha and Numeric</td>
        <td>
            Numeric represents values such as 7, 8, and 9.<br/>
            Alpha represents values such as One Size, S, and XL.<br/>
            Age represents values such as 6 Months and 2 Years.
        </td>
    </tr>
    <tr>
        <td><strong>Apparel Size Body Type</strong></td>
        <td>Conditionally Mandatory - Select the applicable body type.</td>
        <td>Regular, Plus</td>
        <td>Values are dependent on product type and might not be required for specific products or Age Range Descriptions.</td>
    </tr>
    <tr>
        <td><strong>Apparel Size Height Type</strong></td>
        <td>Conditionally Mandatory - Select the applicable height type.</td>
        <td>Petite, Regular, Short, Tall, Extra Tall</td>
        <td>Values are dependent on product type and might not be required for specific products or Age Range Descriptions.</td>
    </tr>
    <tr>
        <td><strong>Apparel Size Value</strong></td>
        <td>Required - Select the applicable apparel size.</td>
        <td>4, S, 3XL, 6 Months, One Size</td>
        <td>Values are dependent on Size Class selection, only numeric values (such as 2, 4, and 6) are valid with the size class Numeric.</td>
    </tr>
    <tr>
        <td><strong>Apparel Size to Value</strong></td>
        <td>Optional - if providing a range of sizes for a product, select the ending apparel size range value here. Valid selection here should be greater than Apparel Size Value.</td>
        <td>6, M, 4XL, 12 Months</td>
        <td>This value is concatenated with Apparel Size Value selection to create a range to display to the customer.</td>
    </tr>
</table>