using System;
using System.Configuration;
using System.Web;
using log4net;

namespace NoPaper.Helpers
{
  public class ConfigHandler : IHttpHandler
  {
    private static readonly ILog log = LogManager.GetLogger(typeof(ConfigHandler));

    public bool IsReusable => true;

    public void ProcessRequest(HttpContext context)
    {
      try
      {
        context.Response.ContentType = "application/javascript";

        var maxLength = ConfigurationManager.AppSettings["MaxPyramidBarCodeLength"];

        var rulesJson = HttpUtility.HtmlDecode(
          ConfigurationManager.AppSettings["BarCodeRules"] ?? "[]"
        );

        var shipRulesJson = HttpUtility.HtmlDecode(
          ConfigurationManager.AppSettings["ShipRules"] ?? "[]"
        );

        context.Response.Write($@"
          window.appConfig = window.appConfig || {{}};
          window.appConfig.maxPyramidBarCodeLength = {maxLength};
          window.appConfig.rules = {rulesJson};
          window.appConfig.shipRules = {shipRulesJson};
        ");
      }
      catch (Exception ex)
      {
        log.Error("ConfigHandler error", ex);
        throw;
      }
    }
  }
}