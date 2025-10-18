data "aws_cloudfront_cache_policy" "caching_optimized" { name="Managed-CachingOptimized" }
data "aws_cloudfront_cache_policy" "caching_disabled"  { name="Managed-CachingDisabled" }
data "aws_cloudfront_response_headers_policy" "cors"    { name="Managed-CORS-with-preflight-and-SecurityHeadersPolicy" }
data "aws_cloudfront_origin_request_policy" "all_viewer_except_host" { name="Managed-AllViewerExceptHostHeader" }
resource "aws_cloudfront_origin_access_control" "oac" { name="site-oac", origin_access_control_origin_type="s3", signing_behavior="always", signing_protocol="sigv4" }
locals { has_api = var.enable_api_path && var.api_domain_name != null && var.api_domain_name != "" }
resource "aws_cloudfront_distribution" "this" {
  enabled=true, comment=var.comment, price_class=var.price_class, aliases=var.aliases, default_root_object="index.html"
  origin { domain_name=var.s3_domain_name, origin_id="s3-origin", origin_access_control_id=aws_cloudfront_origin_access_control.oac.id }
  dynamic "origin" {
    for_each = local.has_api ? [1] : []
    content {
      domain_name = var.api_domain_name
      origin_id   = "api-origin"
      custom_origin_config { https_port=443, origin_protocol_policy="https-only", origin_ssl_protocols=["TLSv1.2"] }
      dynamic "origin_custom_headers" {
        for_each = var.api_shared_secret == null ? [] : [1]
        content { name="X-Shared-Secret", value=var.api_shared_secret }
      }
    }
  }
  default_cache_behavior {
    target_origin_id="s3-origin"
    viewer_protocol_policy="redirect-to-https"
    allowed_methods=["GET","HEAD"]
    cached_methods=["GET","HEAD"]
    compress=true
    cache_policy_id=data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id=data.aws_cloudfront_response_headers_policy.cors.id
  }
  dynamic "ordered_cache_behavior" {
    for_each = local.has_api ? [1] : []
    content {
      path_pattern="/api/*"
      target_origin_id="api-origin"
      viewer_protocol_policy="https-only"
      allowed_methods=["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
      cached_methods=["GET","HEAD","OPTIONS"]
      cache_policy_id=data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id=data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
    }
  }
  restrictions { geo_restriction { restriction_type="none" } }
  viewer_certificate { cloudfront_default_certificate=true }
  tags=var.tags
}
