# id=272 = Spachtelmasse

UPDATE s_articles SET taxID = 1 WHERE id = 272;
UPDATE s_articles_prices SET price = 7.56 WHERE articleID = 272;
UPDATE s_core_customergroups SET tax = 0, taxinput = 0, minimumorder = 0, minimumordersurcharge = 0;
DELETE FROM s_premium_dispatch WHERE name NOT LIKE "%Standard%";
UPDATE s_premium_shippingcosts SET value = 5.20;