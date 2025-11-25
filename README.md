# Stationery - Business Scenario
Implement the following business scenario in T-SQL. Create the tables, insert the data, and write the reports.
I run a small business called Sunrise Stationery, an online shop that sells notebooks, pens, and desk accessories to schools and home offices. I’ve just hired you as my developer to help me organize my information in a structured way so I can answer business questions more easily.

Below is how I would explain everything to you as the business owner.

1. The core of my business

From my point of view, I really only care about three main things:

My customers – who they are and how to reach them

My products – what I sell and how much stock I have

My orders – who bought what, when, and for how much

Behind the scenes, you told me you’ll keep this in a few structured lists:

A list of customers

A list of products

A list of orders

A list of order line items (each item inside an order)

(I don’t need to know how you store it technically; I just need it to be consistent and accurate.)

2. Sample data I expect you to start with
2.1 Customers

Here are some example customers I already have:

Customer ID	First Name	Last Name	Email	City	Customer Type
C001	Sarah	Cohen	sarah.cohen@example.com
	Jerusalem	School
C002	David	Levi	david.levi@example.com
	Tel Aviv	Home Office
C003	Rachel	Ben Ami	rachel.ba@example.com
	Haifa	School
C004	Noam	Adler	noam.adler@example.com
	Be’er Sheva	Freelancer
C005	Maya	Katz	maya.katz@example.com
	Jerusalem	Home Office
2.2 Products

These are some of the products I sell:

Product ID	Product Name	Category	Unit Price	Units in Stock	Reorder Level
P001	A5 Lined Notebook	Notebooks	12.00	150	50
P002	Blue Gel Pen (Pack 10)	Pens	18.00	80	30
P003	Highlighter Set (4)	Markers	24.00	40	20
P004	Desk Organizer Tray	Desk Accessory	45.00	25	10
P005	A4 Graph Paper Pad	Notebooks	15.00	60	25
2.3 Orders (header)

Each order is placed by one customer on a specific date:

Order ID	Customer ID	Order Date	Status	Shipping City
O1001	C001	2025-01-10	Shipped	Jerusalem
O1002	C002	2025-01-11	Delivered	Tel Aviv
O1003	C001	2025-01-15	Delivered	Jerusalem
O1004	C003	2025-01-16	Pending	Haifa
O1005	C005	2025-01-17	Shipped	Jerusalem
2.4 Order line items

Each order can have one or more products inside it. For each item, I need to know which product, how many, and the price at the time:

Order ID	Line No	Product ID	Quantity	Unit Price at Time	Discount %
O1001	1	P001	30	12.00	0
O1001	2	P002	10	18.00	5
O1002	1	P004	2	45.00	0
O1002	2	P003	3	24.00	0
O1003	1	P001	20	12.00	10
O1003	2	P005	15	15.00	0
O1004	1	P002	20	18.00	5
O1005	1	P003	5	24.00	0
O1005	2	P004	1	45.00	0
3. Business rules I care about

These are the rules I want you, as the developer, to enforce in the system. I’ll say them in plain business language.

3.1 Customer rules

Every customer must have:

A unique ID

A name (first and last)

A valid email address

Two different customers must not share the same email address.

Customer types must be from a fixed list: School, Home Office, Freelancer, or Other.

3.2 Product rules

Prices must be positive (I never sell anything with price zero or less).

Stock cannot be negative.

If stock reaches or goes below the reorder level, I want to see that product flagged as “Needs Restock.”

The category must be one of: Notebooks, Pens, Markers, Desk Accessory, or Other.

Once a product is discontinued (in future, if we add such a field), it must not appear in new orders.

3.3 Order rules

An order must always belong to a real customer from the customer list.

An order must have at least one line item.

Each line item must refer to a real product from the product list.

Quantity must be at least 1.

When an order is confirmed:

The stock for each product in that order must decrease by the quantity ordered.

If that would send stock below zero, the order should be rejected or flagged for review.

Order status must be one of: Pending, Shipped, Delivered, or Cancelled.

Discounts are stored as percentages between 0 and 100.

4. Conversation between me (business owner) and you (developer)

Here’s how I imagine one of our planning conversations would go.

Owner: I need to understand which customers are ordering the most from me, so I can give them special offers.
Developer: Understood. I’ll track the total amount each customer spends and the number of orders they place. Then I can give you a list sorted from highest to lowest.

Owner: I also want to know when I’m about to run out of a product. Right now, I notice too late.
Developer: I’ll keep an up-to-date “stock on hand” value for each product, and compare it to a “reorder level” that you set. Whenever the stock is at or below that level, I’ll mark it as needing restock so we can report on it.

Owner: Great. For schools, they usually order in bigger quantities than home offices. Can you help me see the difference?
Developer: Yes. Since I’m storing a “customer type” for each customer, I can compare total sales by customer type: schools versus home offices versus freelancers, and so on.

Owner: I want to keep a history of the price at the time of each order, because I sometimes run promotions.
Developer: Already planned. Each item in an order will store its own “price at the time of order” instead of looking at the current product price. That way, if you change your prices later, past orders will still show the old price.

Owner: Sometimes I offer a discount for big notebook orders, like 10% off. Can that be reflected?
Developer: Yes. Each line item can have a discount percentage. I’ll calculate the line total as: quantity × price × (100 − discount) / 100.

Owner: I’d like to see what I sold today, this week, and this month.
Developer: I’ll record the date of each order. Then we can create reports that filter by different date ranges.

Owner: What about customers who haven’t ordered in a while? I’d like to send them a reminder or coupon.
Developer: Since we have the date of each customer’s most recent order, I can show you those who haven’t placed an order in, say, the last 60 days.

5. Sample reports I want you to produce

Here are a couple of specific reports I’d ask you to generate regularly. You will turn these into actual queries later, but this is what I want to see as a business owner.

5.1 Report: Top customers by total spending this month

Purpose: Reward loyal customers and understand who brings in the most revenue.

Filter: Orders with an order date in the current month and with status “Shipped” or “Delivered”.

What I want in the report:

Rank	Customer Name	Customer Type	Number of Orders	Total Quantity Ordered	Total Amount Spent
1	Sarah Cohen	School	2	65	1,290.00
2	David Levi	Home Office	1	5	177.00
3	Maya Katz	Home Office	1	6	165.00

(Numbers above are just an example based on the sample data.)

This helps me answer questions like:

Who are my top 10 customers this month?

Are schools really buying more than home offices?

How much did each type of customer contribute?

5.2 Report: Products that need restocking

Purpose: Make sure I don’t run out of popular items.

Filter: Products where current stock is less than or equal to the “reorder level”.

What I want in the report:

Product ID	Product Name	Category	Units in Stock	Reorder Level	Needs Restock?
P002	Blue Gel Pen (Pack 10)	Pens	30	30	Yes
P003	Highlighter Set (4)	Markers	18	20	Yes
P004	Desk Organizer Tray	Desk Accessory	5	10	Yes

This tells me:

Which products I should reorder immediately

Which categories are running low more often

Whether I need to adjust the reorder level (for example, if something is always low)

5.3 Optional extra report: Daily sales summary

If we go a bit further, I would also love a daily summary:

Date	Number of Orders	Total Items Sold	Total Revenue
2025-01-10	1	40	366.00
2025-01-11	1	5	162.00
2025-01-15	1	35	435.00
2025-01-16	1	20	342.00
2025-01-17	1	6	165.00

This helps me see:

Which days are busiest

How sales are trending over time

Whether promotions or campaigns had an effect
