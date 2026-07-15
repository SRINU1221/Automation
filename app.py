"""
app.py — Entry point.
Multi-Plant and Plant Config pages are shown in the sidebar.
"""
import streamlit as st

pg = st.navigation([
    st.Page("pages/multi_plant.py", title="Multi-Plant Automation", icon="🏭"),
    st.Page("pages/_plant_config.py", title="Plant Config", icon="⚙️"),
])
pg.run()
