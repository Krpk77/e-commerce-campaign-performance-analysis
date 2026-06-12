USE campaign_dataset;
GO

--data exploration
select * from campaigns;
select * from campaign_interaction;
select * from customers;
select * from conversion;


select count(*) as total_customers
from customers

select distinct customer_segment
from customers;

--total interaction per campaign (Which campaign generated the most engagement)
select c.campaign_name, count(ci.interaction_id) as interactions
from campaign_interaction ci
join campaigns c on 
c.campaign_id = ci.campaign_id
group by c.campaign_name
order by interactions desc;

--total revenue by campaign_type (Which campaign made the most money)
select c.campaign_type, round(sum(cr.revenue_amount), 0) as total_revenue
from conversion cr
join campaigns c on c.campaign_id=cr.campaign_id
group by c.campaign_type
order by total_revenue desc;

--conversion rate (Which campaign converts visitors into buyers most effectively)
select ci.campaign_id, 
count(distinct cr.conversion_id) * 100 / count(distinct ci.interaction_id) as conversion_rate
from conversion cr
left join campaign_interaction ci on ci.campaign_id=cr.campaign_id
group by ci.campaign_id;

--clicks by campaign (campaigns generating most engagement)
select ci.campaign_id, c.campaign_type, count(interaction_id) as clicks
from campaign_interaction ci
left join campaigns c on c.campaign_id=ci.campaign_id
where ci.interaction_type = 'Click'
group by ci.campaign_id, c.campaign_type;

--calculate CTR 
select ci.campaign_id, c.campaign_type,
sum(case when ci.interaction_type = 'click' then 1 end) as clicks,
sum(case when ci.interaction_type = 'view' then 1 end) as impressions,

sum(case when ci.interaction_type = 'click' then 1 end) * 100 /
sum(case when ci.interaction_type = 'view' then 1 end) as CTR
from campaign_interaction ci
left join campaigns c on c.campaign_id=ci.campaign_id
group by ci.campaign_id, c.campaign_type;

--channel generating highest number of conversions
select cu.acquisition_channel, count(distinct conversion_id) as conversions
from conversion cr
left join customers cu on cu.customer_id=cr.customer_id
group by cu.acquisition_channel
order by conversions desc;

--customer segment analysis (segment of customers brings the most revenue)
select cu.customer_segment , round(sum(cr.revenue_amount), 0) as total_revenue
from conversion cr
left join customers cu on cu.customer_id=cr.customer_id
group by cu.customer_segment
order by total_revenue desc;

--AOV by campaigns (which campaign attracts higher value customers)
select c.campaign_name, avg(cr.revenue_amount) as AOV
from conversion cr
join campaigns c on c.campaign_id=cr.campaign_id
group by c.campaign_name
order by AOV desc;

--ROI (which campaign deserves more budget)
select c.campaign_name, c.campaign_type, c.budget, sum(cr.revenue_amount) as revenue, 
(sum(cr.revenue_amount)-c.budget)*100 / c.budget as ROI
from campaigns c
left join conversion cr on c.campaign_id=cr.campaign_id
group by c.campaign_name, c.campaign_type, c.budget;
