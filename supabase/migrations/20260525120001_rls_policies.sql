-- RLS policies for multi-tenant tables (shop_id on sale = auth user id via shop_profile).

CREATE POLICY "shop_profile_select_own"
    ON public.shop_profile FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "shop_profile_insert_own"
    ON public.shop_profile FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "shop_profile_update_own"
    ON public.shop_profile FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "sale_all_own_shop"
    ON public.sale FOR ALL
    USING (auth.uid() = shop_id)
    WITH CHECK (auth.uid() = shop_id);

CREATE POLICY "sale_item_all_own_shop"
    ON public.sale_item FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.sale s
            WHERE s.id = sale_item.sale_id AND s.shop_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.sale s
            WHERE s.id = sale_item.sale_id AND s.shop_id = auth.uid()
        )
    );
