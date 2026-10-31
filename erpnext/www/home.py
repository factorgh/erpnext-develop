import frappe


def get_context(context):
	context.no_cache = 1
	context.no_breadcrumbs = True
	context.show_sidebar = False
	context.full_width = 1
	context.title = "LedstackERP"
	context.logged_in = frappe.session.user and frappe.session.user != "Guest"
