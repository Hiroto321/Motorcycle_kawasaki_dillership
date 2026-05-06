CREATE INDEX idx_categories_series ON public.categories USING btree (series_id);
CREATE INDEX idx_model_series_group ON public.model_series USING btree (group_id);

CREATE INDEX idx_motorcycles_category ON public.motorcycles USING btree (category_id);
CREATE INDEX idx_motorcycles_model_name ON public.motorcycles USING btree (model_name);
CREATE INDEX idx_motorcycles_price ON public.motorcycles USING btree (price);
CREATE INDEX idx_motorcycles_price_year ON public.motorcycles USING btree (price, year);
CREATE INDEX idx_motorcycles_year ON public.motorcycles USING btree (year);

CREATE INDEX idx_order_items_motorcycle_id ON public.order_items USING btree (motorcycle_id);
CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);
CREATE INDEX idx_orders_date ON public.orders USING btree (order_date);
CREATE INDEX idx_orders_status ON public.orders USING btree (status);
CREATE INDEX idx_orders_user_id ON public.orders USING btree (user_id);

CREATE UNIQUE INDEX idx_users_email ON public.users USING btree (email);
CREATE UNIQUE INDEX idx_users_username ON public.users USING btree (user_name);

CREATE INDEX idx_notifications_created_at ON public.system_notifications USING btree (created_at);
CREATE INDEX idx_notifications_is_read ON public.system_notifications USING btree (is_read);
CREATE INDEX idx_notifications_user_id ON public.system_notifications USING btree (user_id);