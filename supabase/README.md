# Supabase schema

Migrations in `migrations/` define multi-tenant tables aligned with the Flutter app (`"Category"`, `"Product"`).

Apply locally or on the linked project:

```bash
supabase db push
```

Or run each `.sql` file in the Supabase SQL editor (Dashboard → SQL).

**Tables**

| Table | Role |
|-------|------|
| `shop_profile` | Tenant root (id = `auth.users.id`) |
| `sale` / `sale_item` | Sales header and line items |
| `"Category"."shopId"` / `"Product"."shopId"` | Optional tenant scope on inventory |

If your remote DB already uses lowercase `category` / `product` and column `shop_id`, adjust quoted identifiers in the migration before applying.
