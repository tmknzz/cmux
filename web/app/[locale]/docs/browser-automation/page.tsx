import { useTranslations } from "next-intl";
import { getTranslations } from "next-intl/server";
import { buildAlternates } from "../../../../i18n/seo";
import { CodeBlock } from "../../components/code-block";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "docs.browserAutomation" });
  return {
    title: t("metaTitle"),
    description: t("metaDescription"),
    alternates: buildAlternates(locale, "/docs/browser-automation"),
  };
}

export default function BrowserAutomationPage() {
  const t = useTranslations("docs.browserAutomation");

  return (
    <>
      <h1>{t("title")}</h1>
      <p>{t("intro")}</p>

      <h2>{t("commandIndex")}</h2>
      <table>
        <thead>
          <tr>
            <th>{t("categoryHeader")}</th>
            <th>{t("subcommandsHeader")}</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>{t("navAndTargeting")}</td>
            <td>
              <code>identify</code>, <code>open</code>, <code>open-split</code>,{" "}
              <code>navigate</code>, <code>back</code>, <code>forward</code>,{" "}
              <code>reload</code>, <code>url</code>, <code>focus-webview</code>,{" "}
              <code>is-webview-focused</code>
            </td>
          </tr>
          <tr>
            <td>{t("waiting")}</td>
            <td>
              <code>wait</code>
            </td>
          </tr>
          <tr>
            <td>{t("domInteraction")}</td>
            <td>
              <code>click</code>, <code>dblclick</code>, <code>hover</code>,{" "}
              <code>focus</code>, <code>check</code>, <code>uncheck</code>,{" "}
              <code>scroll-into-view</code>, <code>type</code>, <code>fill</code>,{" "}
              <code>press</code>, <code>keydown</code>, <code>keyup</code>,{" "}
              <code>select</code>, <code>scroll</code>
            </td>
          </tr>
          <tr>
            <td>{t("inspection")}</td>
            <td>
              <code>snapshot</code>, <code>screenshot</code>, <code>get</code>,{" "}
              <code>is</code>, <code>find</code>, <code>highlight</code>
            </td>
          </tr>
          <tr>
            <td>{t("jsAndInjection")}</td>
            <td>
              <code>eval</code>, <code>addinitscript</code>, <code>addscript</code>,{" "}
              <code>addstyle</code>
            </td>
          </tr>
          <tr>
            <td>{t("framesDialogsDownloads")}</td>
            <td>
              <code>frame</code>, <code>dialog</code>, <code>download</code>
            </td>
          </tr>
          <tr>
            <td>{t("stateAndSession")}</td>
            <td>
              <code>cookies</code>, <code>storage</code>, <code>state</code>
            </td>
          </tr>
          <tr>
            <td>{t("tabsAndLogs")}</td>
            <td>
              <code>tab</code>, <code>console</code>, <code>errors</code>
            </td>
          </tr>
        </tbody>
      </table>

      <h2>{t("targetingSurface")}</h2>
      <p>{t("targetingDesc")}</p>
      <CodeBlock lang="bash">{`# Open a new browser split
cmuxplus browser open https://example.com

# Discover focused IDs and browser metadata
cmuxplus browser identify
cmuxplus browser identify --surface surface:2

# Positional vs flag targeting are equivalent
cmuxplus browser surface:2 url
cmuxplus browser --surface surface:2 url`}</CodeBlock>

      <h2>{t("navigation")}</h2>
      <CodeBlock lang="bash">{`cmuxplus browser open https://example.com
cmuxplus browser open-split https://news.ycombinator.com

cmuxplus browser surface:2 navigate https://example.org/docs --snapshot-after
cmuxplus browser surface:2 back
cmuxplus browser surface:2 forward
cmuxplus browser surface:2 reload --snapshot-after
cmuxplus browser surface:2 url

cmuxplus browser surface:2 focus-webview
cmuxplus browser surface:2 is-webview-focused`}</CodeBlock>

      <h2>{t("waitingSection")}</h2>
      <p>{t("waitingDesc")}</p>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 wait --load-state complete --timeout-ms 15000
cmuxplus browser surface:2 wait --selector "#checkout" --timeout-ms 10000
cmuxplus browser surface:2 wait --text "Order confirmed"
cmuxplus browser surface:2 wait --url-contains "/dashboard"
cmuxplus browser surface:2 wait --function "window.__appReady === true"`}</CodeBlock>

      <h2>{t("domSection")}</h2>
      <p>{t("domDesc")}</p>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 click "button[type='submit']" --snapshot-after
cmuxplus browser surface:2 dblclick ".item-row"
cmuxplus browser surface:2 hover "#menu"
cmuxplus browser surface:2 focus "#email"
cmuxplus browser surface:2 check "#terms"
cmuxplus browser surface:2 uncheck "#newsletter"
cmuxplus browser surface:2 scroll-into-view "#pricing"

cmuxplus browser surface:2 type "#search" "cmux"
cmuxplus browser surface:2 fill "#email" --text "ops@example.com"
cmuxplus browser surface:2 fill "#email" --text ""
cmuxplus browser surface:2 press Enter
cmuxplus browser surface:2 keydown Shift
cmuxplus browser surface:2 keyup Shift
cmuxplus browser surface:2 select "#region" "us-east"
cmuxplus browser surface:2 scroll --dy 800 --snapshot-after
cmuxplus browser surface:2 scroll --selector "#log-view" --dx 0 --dy 400`}</CodeBlock>

      <h2>{t("inspectionSection")}</h2>
      <p>{t("inspectionDesc")}</p>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 snapshot --interactive --compact
cmuxplus browser surface:2 snapshot --selector "main" --max-depth 5
cmuxplus browser surface:2 screenshot --out /tmp/cmux-page.png

cmuxplus browser surface:2 get title
cmuxplus browser surface:2 get url
cmuxplus browser surface:2 get text "h1"
cmuxplus browser surface:2 get html "main"
cmuxplus browser surface:2 get value "#email"
cmuxplus browser surface:2 get attr "a.primary" --attr href
cmuxplus browser surface:2 get count ".row"
cmuxplus browser surface:2 get box "#checkout"
cmuxplus browser surface:2 get styles "#total" --property color

cmuxplus browser surface:2 is visible "#checkout"
cmuxplus browser surface:2 is enabled "button[type='submit']"
cmuxplus browser surface:2 is checked "#terms"

cmuxplus browser surface:2 find role button --name "Continue"
cmuxplus browser surface:2 find text "Order confirmed"
cmuxplus browser surface:2 find label "Email"
cmuxplus browser surface:2 find placeholder "Search"
cmuxplus browser surface:2 find alt "Product image"
cmuxplus browser surface:2 find title "Open settings"
cmuxplus browser surface:2 find testid "save-btn"
cmuxplus browser surface:2 find first ".row"
cmuxplus browser surface:2 find last ".row"
cmuxplus browser surface:2 find nth 2 ".row"

cmuxplus browser surface:2 highlight "#checkout"`}</CodeBlock>

      <h2>{t("jsSection")}</h2>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 eval "document.title"
cmuxplus browser surface:2 eval --script "window.location.href"

cmuxplus browser surface:2 addinitscript "window.__cmuxReady = true;"
cmuxplus browser surface:2 addscript "document.querySelector('#name')?.focus()"
cmuxplus browser surface:2 addstyle "#debug-banner { display: none !important; }"`}</CodeBlock>

      <h2>{t("stateSection")}</h2>
      <p>{t("stateDesc")}</p>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 cookies get
cmuxplus browser surface:2 cookies get --name session_id
cmuxplus browser surface:2 cookies set session_id abc123 --domain example.com --path /
cmuxplus browser surface:2 cookies clear --name session_id
cmuxplus browser surface:2 cookies clear --all

cmuxplus browser surface:2 storage local set theme dark
cmuxplus browser surface:2 storage local get theme
cmuxplus browser surface:2 storage local clear
cmuxplus browser surface:2 storage session set flow onboarding
cmuxplus browser surface:2 storage session get flow

cmuxplus browser surface:2 state save /tmp/cmux-browser-state.json
cmuxplus browser surface:2 state load /tmp/cmux-browser-state.json`}</CodeBlock>

      <h2>{t("tabsSection")}</h2>
      <p>{t("tabsDesc")}</p>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 tab list
cmuxplus browser surface:2 tab new https://example.com/pricing

# Switch by index or by target surface
cmuxplus browser surface:2 tab switch 1
cmuxplus browser surface:2 tab switch surface:7

# Close current tab or a specific target
cmuxplus browser surface:2 tab close
cmuxplus browser surface:2 tab close surface:7`}</CodeBlock>

      <h2>{t("consoleSection")}</h2>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 console list
cmuxplus browser surface:2 console clear

cmuxplus browser surface:2 errors list
cmuxplus browser surface:2 errors clear`}</CodeBlock>

      <h2>{t("dialogsSection")}</h2>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 dialog accept
cmuxplus browser surface:2 dialog accept "Confirmed by automation"
cmuxplus browser surface:2 dialog dismiss`}</CodeBlock>

      <h2>{t("framesSection")}</h2>
      <CodeBlock lang="bash">{`# Enter an iframe context
cmuxplus browser surface:2 frame "iframe[name='checkout']"
cmuxplus browser surface:2 click "#pay-now"

# Return to the top-level document
cmuxplus browser surface:2 frame main`}</CodeBlock>

      <h2>{t("downloadsSection")}</h2>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 click "a#download-report"
cmuxplus browser surface:2 download --path /tmp/report.csv --timeout-ms 30000`}</CodeBlock>

      <h2>{t("commonPatterns")}</h2>

      <h3>{t("patternNavigate")}</h3>
      <CodeBlock lang="bash">{`cmuxplus browser open https://example.com/login
cmuxplus browser surface:2 wait --load-state complete --timeout-ms 15000
cmuxplus browser surface:2 snapshot --interactive --compact
cmuxplus browser surface:2 get title`}</CodeBlock>

      <h3>{t("patternForm")}</h3>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 fill "#email" --text "ops@example.com"
cmuxplus browser surface:2 fill "#password" --text "$PASSWORD"
cmuxplus browser surface:2 click "button[type='submit']" --snapshot-after
cmuxplus browser surface:2 wait --text "Welcome"
cmuxplus browser surface:2 is visible "#dashboard"`}</CodeBlock>

      <h3>{t("patternDebug")}</h3>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 console list
cmuxplus browser surface:2 errors list
cmuxplus browser surface:2 screenshot --out /tmp/cmux-failure.png
cmuxplus browser surface:2 snapshot --interactive --compact`}</CodeBlock>

      <h3>{t("patternSession")}</h3>
      <CodeBlock lang="bash">{`cmuxplus browser surface:2 state save /tmp/session.json
# ...later...
cmuxplus browser surface:2 state load /tmp/session.json
cmuxplus browser surface:2 reload`}</CodeBlock>
    </>
  );
}
