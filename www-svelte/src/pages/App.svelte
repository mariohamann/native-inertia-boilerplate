<script lang="ts">
	import { router } from "@inertiajs/svelte";
	import { onMount } from "svelte";

	onMount(() => {
		router.get("/");
	});
</script>

<header />

<main>Redirect to Root...</main>

<style></style>
