import { getCliClient } from 'sanity/cli'
import createClient from 'openapi-fetch'
import { paths } from '../openapi/behandling-typer'

const sanityClient = getCliClient()

// const behandlingClient = createClient<paths>({ baseUrl: getEnv("DP_BEHANDLING_URL") });
const behandlingClient = createClient<paths>({
  baseUrl: 'https://dp-behandling.intern.dev.nav.no',
})

async function hentOpplysninger() {
  const onBehalfOfToken = 'TOKEN'
  const { data, error, response } = await behandlingClient.GET('/opplysningstyper', {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
      Authorization: `Bearer ${onBehalfOfToken}`,
      connection: 'keep-alive',
    },
  })

  if (data) {
    return data
  }

  if (error) {
    throw new Error(error)
  }

  throw new Error(
    `Uhåndtert feil i hentOpplysninger(). ${response.status} - ${response.statusText}`,
  )
}

async function syncOpplysninger() {
  const opplysninger = await hentOpplysninger()

  for (const opplysning of opplysninger) {
    await sanityClient.createOrReplace({
      _type: 'regelmotorOpplysning',
      language: 'nb',
      opplysningTypeId: opplysning.opplysningTypeId,
      navn: opplysning.navn,
      type: opplysning.datatype,
    })

    console.info(`Synced: ${opplysning.navn}`)
  }

  console.info(`Done! Synced ${opplysninger.length} opplysninger`)
}

syncOpplysninger().catch(console.error)
