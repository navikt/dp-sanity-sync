import { requestAzureClientCredentialsToken } from "@navikt/oasis";
import { createClient as createSanityClient } from "@sanity/client";
import { load } from "@std/dotenv";
import createClient from "openapi-fetch";
import { opplysningstyperMock } from "./mock.ts";
import { paths } from "./openapi/behandling-typer.ts";

await load({
  export: true,
});

const dataset = Deno.env.get("SANITY_DATASET") || "development";
const token = Deno.env.get("SANITY_TOKEN") || "";
const dryRun = Deno.env.get("DRY_RUN") === "true";

const sanityClient = createSanityClient({
  projectId: "rt6o382n",
  dataset,
  token,
  useCdn: false,
  apiVersion: "2021-10-01",
});

  const behandlingClient = createClient<paths>({
    baseUrl: Deno.env.get("DP_BEHANDLING_URL"),
  });


async function hentOpplysninger() {
  if (Deno.env.get("IS_LOCALHOST") === "true") {
    return opplysningstyperMock;
  }
  const audience = Deno.env.get("DP_BEHANDLING_AUDIENCE");
  if (!audience) {
    throw new Error("DP_BEHANDLING_AUDIENCE is not set");
  }
  const clientCredentials = await requestAzureClientCredentialsToken(audience);
  if (!clientCredentials.ok) {
    throw new Error(
      `Failed to get client credentials token: ${clientCredentials.error.message}`
    );
  }

  const onBehalfOfToken = clientCredentials.token;

  const { data, response } = await behandlingClient.GET("/opplysningstyper", {
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      Authorization: `Bearer ${onBehalfOfToken}`,
      connection: "keep-alive",
    },
  });

  if (data) {
    return data;
  }

  throw new Error(
    `Uhåndtert feil i hentOpplysninger(). ${response.status} - ${response.statusText}`
  );
}

async function syncOpplysninger() {
  const opplysninger = await hentOpplysninger();
  const dokumenter = await sanityClient.fetch(
    '*[_type == "regelmotorOpplysning"]{opplysningTypeId, _id}'
  );

  console.log(`Fetched ${dokumenter.length} existing documents from Sanity`);

  const transaction = sanityClient.transaction();

  for (const opplysning of opplysninger) {
    const eksisterendeDokument = dokumenter.find(
      (doc: { opplysningTypeId: string; _id: string }) =>
        doc.opplysningTypeId === opplysning.opplysningTypeId
    );

    if (eksisterendeDokument) {
      transaction.patch(eksisterendeDokument._id, {
        set: {
          navn: opplysning.navn,
          datatype: opplysning.datatype,
        },
      });
    } else {
      transaction.create({
        _type: "regelmotorOpplysning",
        opplysningTypeId: opplysning.opplysningTypeId,
        navn: opplysning.navn,
        datatype: opplysning.datatype,
      });
    }
  }

  if (!dryRun) {
    await transaction.commit();
    console.info(
      `Done! Synced ${opplysninger.length} opplysninger in one transaction`
    );
  } else {
    console.info(
      `Dry run: Would have synced ${opplysninger.length} opplysninger`
    );
  }
}

syncOpplysninger().catch(console.error);
